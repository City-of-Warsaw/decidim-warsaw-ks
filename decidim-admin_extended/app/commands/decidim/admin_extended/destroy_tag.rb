# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when destroying a tag.
    class DestroyTag < Rectify::Command
      # Public: Initializes the command.
      #
      # tag - The tag to destroy
      # current_user - the user performing the action
      def initialize(tag, current_user)
        @tag = tag
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        destroy_tag
        broadcast(:ok)
      rescue ActiveRecord::RecordNotDestroyed
        broadcast(:has_spaces)
      end

      private

      attr_reader :current_user

      def destroy_tag
        Decidim.traceability.perform_action!(
          "delete",
          @tag,
          current_user
        ) do
          @tag.destroy!
        end
      end
    end
  end
end
