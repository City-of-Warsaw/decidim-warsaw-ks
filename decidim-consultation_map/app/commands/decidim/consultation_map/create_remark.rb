# frozen_string_literal: true

module Decidim
  module ConsultationMap
    # This class holds logic for creating Remarks on map
    class CreateRemark < Decidim::Command
      include Decidim::CoreExtended::AuthorParamsBuilder
      include Decidim::CoreExtended::GenerateTokenHelper
      include Decidim::ResourceHelper

      # Initializes a CreateRemark Command.
      #
      # form - A form object with the params.
      # current_organization - A current organization object
      # component - A current component object
      # author - registered user or not registered
      def initialize(form, author)
        @form = form
        @current_organization = form.current_organization
        @component = form.component
        @author = author || unregistered_author
      end

      # Creates the remark if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid?

        create_remark
        notify_followers_about_new_remark
        notify_process_admins
        broadcast(:ok)
      end

      private

      def create_remark
        @remark = Decidim.traceability.create!(
          Decidim::ConsultationMap::Remark,
          @author,
          remark_attributes,
          visibility: "public-only"
        )

        @remark.update(author_second_step_params)
      end

      def remark_attributes
        {
          body: @form.body,
          author: @author,
          component: @component,
          category: @form.category,
          locations: prepared_locations,
          latitude: prepared_locations[:latitude],
          longitude: prepared_locations[:longitude],
          signature: signature_or_editorial,
          token: generate_token
        }.tap do |attr|
          attr[:files] = @form.files if @form.files.present?
        end
      end

      # Public method parsing locations data in form
      # to retrieve latitude and longitude to be saved
      #
      # returns Hash
      def prepared_locations
        # returns array of MatchData objects
        # example: [#<MatchData "52.18562699251455" 1:"52.">, #<MatchData "21.119845389621336" 1:"21.">]
        arr = @form.locations.to_enum(:scan, /[+-]?([0-9]*[.])?[0-9]+{2}/).map { Regexp.last_match }

        {
          latitude: arr[0][0],
          longitude: arr[1][0]
        }
      end

      # use first map remark of that component as resource
      # that map remark is followed by users
      def notify_followers_about_new_remark
        system_remark = Decidim::ConsultationMap::Remark.where(
          body: "system_generated_hidden_map_remark",
          component: @component
        ).order(:created_at).first

        return unless system_remark

        Decidim::CoreExtended::TemplatedMailerJob.perform_later('new_map_remark', { resource: system_remark })
      end

      def extract_participatory_process(resource)
        return resource.participatory_space if resource.respond_to?(:participatory_space)

        resource.component.participatory_space if resource.respond_to?(:component)
      end

      def notify_process_admins
        Decidim::CoreExtended::TemplatedMailerJob.perform_later(
          "new_map_remark_for_process_admin",
          {
            resource: @remark,
            process: extract_participatory_process(@remark),
            map_remark_body: @remark.body,
            map_remark_link: resource_locator(@remark).url
          }
        )
      end
    end
  end
end
