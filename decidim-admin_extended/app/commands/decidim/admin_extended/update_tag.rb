# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating an tag.
    class UpdateTag < Rectify::Command
      # Public: Initializes the command.
      #
      # tag - The Tag to update
      # form - A form object with the params.
      # user - A user that performs action
      def initialize(tag, form, user)
        @tag = tag
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

        update_tag
        broadcast(:ok)
      end

      private

      attr_reader :form, :current_user

      # Private: updating tag
      #
      # Method creates ActionLog
      #
      # Returns: Tag
      def update_tag
        Decidim.traceability.update!(
          @tag,
          current_user,
          attributes
        )
      end

      # Private: Hash of tag attributes
      def attributes
        {
          name: form.name
        }
      end
    end
  end
end
