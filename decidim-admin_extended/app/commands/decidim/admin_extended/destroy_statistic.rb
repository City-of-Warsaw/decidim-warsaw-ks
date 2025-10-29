# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when destroying a statistic.
    class DestroyStatistic< Decidim::Command
      # Public: Initializes the command.
      #
      # tag - The tag to destroy
      # current_user - the user performing the action
      def initialize(statistic, current_user)
        @statistic = statistic
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:not_allowed) unless @statistic.deletable

        destroy_statistic
        broadcast(:ok)
      rescue ActiveRecord::RecordNotDestroyed
        broadcast(:invalid)
      end

      private

      attr_reader :current_user

      def destroy_statistic
        Decidim.traceability.perform_action!(
          "delete",
          @statistic,
          current_user
        ) do
          @statistic.destroy!
        end
      end
    end
  end
end
