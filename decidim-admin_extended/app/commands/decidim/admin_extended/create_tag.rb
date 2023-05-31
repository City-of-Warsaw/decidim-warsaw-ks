# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating an tag.
    class CreateTag < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # user - A user that performs action
      def initialize(form, user)
        @form = form
        @current_user = user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        create_tag
        broadcast(:ok)
      end

      private

      attr_reader :form, :current_user

      # Private: creating tag
      #
      # Method creates ActionLog
      #
      # Returns: Tag
      def create_tag
        Decidim.traceability.create!(
          Decidim::AdminExtended::Tag,
          current_user,
          attributes
        )
      end

      # Private: Hash of tag attributes
      def attributes
        {
          name: form.name,
          organization: current_user.organization
        }
      end
    end
  end
end
