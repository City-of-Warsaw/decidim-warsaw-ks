# frozen_string_literal: true

module Decidim
  module AdminExtended
    # This command gets called when a component is enabling functions from the admin panel.
    class EnableAiInComponent < Decidim::Command
      # Public: Initializes the command.
      #
      # component - The component to enable_ai.
      # current_user - the user performing the action
      def initialize(component, current_user)
        @component = component
        @current_user = current_user
      end

      # Public: Enable AI in the Component.
      #
      # Broadcasts :ok if enabled
      def call
        enable_ai_in_component

        broadcast(:ok)
      end

      private

      attr_reader :component, :current_user

      def enable_ai_in_component
        Decidim.traceability.perform_action!(
          :enable_ai,
          component,
          current_user,
          visibility: "admin-only",
          ) do
          component.update!(ai_enabled: true)
          component
        end
      end
    end
  end
end
