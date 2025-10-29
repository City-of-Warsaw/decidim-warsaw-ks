# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when destroying a faq.
    class DestroyFaq < Decidim::Command
      # Public: Initializes the command.
      #
      # faq - The document to faq
      def initialize(faq)
        @faq = faq
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        destroy_faq
        broadcast(:ok)
      end

      private

      attr_reader :faq

      # Private: destroying faq
      #
      # Method destroys faq and creates ActionLog
      def destroy_faq
        Decidim.traceability.perform_action!(
          "delete",
          faq,
          current_user
        ) do
          faq.destroy!
        end
      end
    end
  end
end
