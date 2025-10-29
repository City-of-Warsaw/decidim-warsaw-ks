# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a Statistic Info
    class CreateStatistic < Decidim::Command
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

        create_statistic
        broadcast(:ok)
      end

      private

      attr_reader :form

      # Private method
      #
      # Creates contact info position
      def create_statistic
        @contact_info_position = Decidim.traceability.create!(
          Decidim::AdminExtended::Statistic,
          current_user,
          statistics_params,
          visibility: "admin-only"
        )
      end

      # Private: attributes for contact info position
      #
      # Returns Hash
      def statistics_params
        {
          name: form.name,
          weight: form.weight,
          visibility: form.visibility,
          additional_statistic_number: form.additional_statistic_number,
          deletable: true
        }
      end
    end
  end
end
