# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a faq group.
    class CreateFaqGroup < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
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

        create_faq_group
        broadcast(:ok)
      end

      private

      attr_reader :form, :faq_group

      # Private: creating faq group
      #
      # Method creates faq group and ActionLog
      def create_faq_group
        Decidim.traceability.create!(
          Decidim::AdminExtended::FaqGroup,
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
