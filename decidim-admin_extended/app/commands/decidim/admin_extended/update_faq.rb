# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating a faq.
    class UpdateFaq < Decidim::Command
      # Public: Initializes the command.
      #
      # faq  - faq to update.
      # form - A form object with the params.
      def initialize(faq, form)
        @faq = faq
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_faq
        broadcast(:ok, faq)
      end

      private

      attr_reader :form, :faq

      # Private: updating faq
      #
      # Method updates faq and creates ActionLog
      def update_faq
        Decidim.traceability.update!(
          faq,
          current_user,
          faq_attributes
        )
      end

      # Private: attributes of faq
      #
      # returns Hash
      def faq_attributes
        {
          title: form.title,
          content: form.content,
          published: form.published,
          weight: form.weight,
          faq_group_id: form.faq_group_id
        }
      end
    end
  end
end
