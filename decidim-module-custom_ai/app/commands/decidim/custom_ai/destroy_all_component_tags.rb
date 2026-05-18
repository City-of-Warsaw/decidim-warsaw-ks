# frozen_string_literal: true

module Decidim
  module CustomAi
    # A command with all the business logic when destroying tags belong to component with turned on module AI.
    class DestroyAllComponentTags < Decidim::Command
      # Public: Initializes the command.
      #
      # component - current component with turned on module AI
      # collection - current component tags
      # resource - proxy tag for creating log
      def initialize(component, collection)
        @component = component
        @collection = collection
        @resource = collection.first
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      #
      # Returns nothing.
      def call
        @collection.delete_all
        create_log(@resource)

        broadcast(:ok)
      end

      private

      def create_log(resource)
        Decidim.traceability.perform_action!(
          :destroy_all_of_that_component,
          resource,
          current_user,
          visibility: "admin-only"
        )
      end
    end
  end
end
