# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating a faq group.
    class UpdateFaqGroup < Decidim::Command
      # Public: Initializes the command.
      #
      # faq_group - A faq group to update.
      # form      - A form object with the params.
      def initialize(faq_group, form)
        @faq_group = faq_group
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

        update_faq_group
        broadcast(:ok, faq_group)
      end

      private

      attr_reader :form, :faq_group

      # Private: updating faq group
      #
      # Method updates faq group and creates ActionLog
      def update_faq_group
        Decidim.traceability.update!(
          faq_group,
          current_user,
          faq_group_attributes
        )
      end

      # Private: attributes of faq group
      #
      # returns Hash
      def faq_group_attributes
        {
          title: form.title,
          subtitle: form.subtitle,
          published: form.published,
          weight: form.weight
        }
      end
    end
  end
end
