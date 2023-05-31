# frozen_string_literal: true

module Decidim
  module ConsultationMap
    # This class holds logic for creating Remarks
    # Attributes updated by unregistered user:
    # - signature
    # - email
    # - district_id
    # - age
    # - gender
    class CreateRemark < Rectify::Command
      # Initializes a CreateUserQuestion Command.
      #
      # form - The form from which to get the data.
      # current_user - The current instance of the remark to be updated.
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
      end

      def remark_attributes
        {
          body: @form.body,
          author: @author,
          component: @component,
          # custom
          images: @form.images,
          category: @form.category,
          locations: prepared_locations,
          latitude: prepared_locations[:latitude],
          longitude: prepared_locations[:longitude],
          signature: @form.signature,
          token: generate_token
        }
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

      # Public method setting dummy author instance for current organization.
      # Method is used when remark is left by unregistered author, to be saved as
      # Remark author association
      #
      # returns Object
      def unregistered_author
        Decidim::CommentsExtended::UnregisteredAuthor.where(organization: @current_organization).first
      end

      def generate_token
        @author.is_a?(Decidim::CommentsExtended::UnregisteredAuthor) ? SecureRandom.hex(rand(59)) : nil
      end
    end
  end
end
