# frozen_string_literal: true

module Decidim
  module CustomAi
    # A command with all the business logic when creating an tag.
    class CreateTag < Decidim::Command
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

        create_tag
        broadcast(:ok)
      end

      private

      attr_reader :form

      # Private: creating tag
      #
      # Method creates ActionLog
      #
      # Returns: Tag
      def create_tag
        Decidim.traceability.create!(
          Decidim::CustomAi::Tag,
          current_user,
          attributes
        )
      end

      # Private: Hash of tag attributes
      def attributes
        {
          name: form.name.downcase,
          component: current_component
        }
      end
    end
  end
end
