# frozen_string_literal: true

module Decidim
  module AdminExtended
    # This command gets called when a component is disabling functions from the admin panel.
    class DisableAiInComponent < Decidim::Command
      # Public: Initializes the command.
      #
      # component - The component to enable_ai.
      # current_user - the user performing the action
      def initialize(component, current_user)
        @component = component
        @current_user = current_user
      end

      # Public: Disable AI in the Component.
      #
      # Broadcasts :ok if disabled
      def call
        disable_ai_in_component

        broadcast(:ok)
      end

      private

      attr_reader :component, :current_user

      def disable_ai_in_component
        Decidim.traceability.perform_action!(
          :disable_ai,
          component,
          current_user,
          visibility: "admin-only",
        ) do
          component.update!(ai_enabled: false)
          component
        end
      end
    end
  end
end
