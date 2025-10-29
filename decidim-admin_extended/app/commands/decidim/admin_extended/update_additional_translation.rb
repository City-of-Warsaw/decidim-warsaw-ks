# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating an additional translation.
    class UpdateAdditionalTranslation < Decidim::Command
      # Public: Initializes the command.
      #
      # translation - The additional translation to update
      # form - A form object with the params.
      # user - A user that performs action
      def initialize(translation, form, user)
        @translation = translation
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

        update_translation
        broadcast(:ok)
      end

      private

      attr_reader :form, :current_user

      # Private: updating translation
      #
      # Method creates ActionLog
      #
      # Returns: translation
      def update_translation
        Decidim.traceability.update!(
          @translation,
          current_user,
          attributes,
          resource: {
            key: @translation.key
          }
        )
      end

      # Private: Hash of translation attributes
      def attributes
        {
          value: form.value
        }
      end
    end
  end
end
