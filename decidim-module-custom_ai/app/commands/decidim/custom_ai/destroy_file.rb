# frozen_string_literal: true

module Decidim
  module CustomAi
    # A command with all the business logic when destroying a file.
    class DestroyFile < Decidim::Command
      # Public: Initializes the command.
      #
      # file - file to be destroyed.
      def initialize(file)
        @file = file
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      #
      # Returns nothing.
      def call
        broadcast_to_ai_about_file_to_be_destroyed(@file)
        destroy_file!

        broadcast(:ok)
      end

      private

      def broadcast_to_ai_about_file_to_be_destroyed(file)
        Decidim::CustomAi::InformAiDestroyedFileJob.perform_later(file.id, current_component)
      end

      def destroy_file!
        Decidim.traceability.perform_action!(
          "delete",
          @file,
          current_user
        ) do
          @file.destroy!
        end
      end
    end
  end
end
