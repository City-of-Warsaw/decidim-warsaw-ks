# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when destroying a faq group.
    class DestroyFaqGroup < Decidim::Command
      # Public: Initializes the command.
      #
      # faq_group - The faq group to destroy
      def initialize(faq_group)
        @faq_group = faq_group
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        destroy_faq_group
        broadcast(:ok)
      end

      private

      attr_reader :faq_group

      # Private: destroying faq group
      #
      # Method destroys faq group and creates ActionLogs
      def destroy_faq_group
        if faq_group.faqs.any?
          faq_group.faqs.each do |faq|
            Decidim.traceability.perform_action!(
              "delete",
              faq,
              current_user
            )
          end
        end

        Decidim.traceability.perform_action!(
          "delete",
          faq_group,
          current_user
        ) do
          faq_group.destroy!
        end
      end
    end
  end
end
