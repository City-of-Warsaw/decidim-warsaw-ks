# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating statistic.
    class UpdateStatistic < Rectify::Command
      # Public: Initializes the command.
      #
      # statistic - The Statistic to update
      # form - A form object with the params.
      def initialize(statistic, form)
        @statistic = statistic
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

        update_statistic
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_statistic
        Decidim.traceability.update!(
          @statistic,
          form.current_user,
          attributes
        )
      end

      def attributes
        {
          name: form.name,
          weight: form.weight,
          visibility: form.visibility
        }
      end
    end
  end
end
