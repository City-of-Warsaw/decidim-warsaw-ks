# frozen_string_literal: true

module Decidim
  module Remarks
    # This class holds logic for creating Remarks
    class CreateRemark < Decidim::Command
      include Decidim::ResourceHelper
      include Decidim::CoreExtended::AuthorParamsBuilder
      include Decidim::CoreExtended::GenerateTokenHelper

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
        broadcast(:ok, @remark)
      end

      private

      def create_remark
        @remark = Decidim.traceability.create!(
          Decidim::Remarks::Remark,
          @author,
          remark_attributes,
          visibility: "public-only"
        )

        @remark.update(author_second_step_params)
      end

      def remark_attributes
        {
          body: @form.body,
          signature: signature_or_editorial,
          author: @author,
          component: @component,
          token: generate_token
        }.tap do |attr|
          attr[:files] = @form.files if @form.files.present?
        end
      end

      # use first remark of that component as resource
      # that remark is followed by users
      def notify_followers_about_new_remark
        system_remark = Decidim::Remarks::Remark.where(
          body: "system_generated_hidden_remark",
          component: @component
        ).order(:created_at).first

        return unless system_remark

        Decidim::CoreExtended::TemplatedMailerJob.perform_later('new_remark', { resource: system_remark, remark_body: @remark.body })
      end

      def extract_participatory_process(resource)
        return resource.participatory_space if resource.respond_to?(:participatory_space)

        resource.component.participatory_space if resource.respond_to?(:component)
      end

      def notify_process_admins
        Decidim::CoreExtended::TemplatedMailerJob.perform_later(
          "new_comment_or_remark_for_process_admin",
          resource: @remark,
          process: extract_participatory_process(@remark),
          remark_or_its_comment_body: @remark.body,
          remark_or_its_comment_link: resource_locator(@remark).url
        )
      end
    end
  end
end
