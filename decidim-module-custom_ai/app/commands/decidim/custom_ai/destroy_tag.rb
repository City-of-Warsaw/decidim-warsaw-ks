# frozen_string_literal: true

module Decidim
  module CustomAi
    # A command with all the business logic when destroying a tag.
    class DestroyTag < Decidim::Command
      # Public: Initializes the command.
      #
      # tag - The tag to destroy
      def initialize(tag)
        @tag = tag
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
      end

      private

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
