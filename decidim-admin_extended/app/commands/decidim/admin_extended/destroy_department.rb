# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when destroying a department.
    class DestroyDepartment < Rectify::Command
      # Public: Initializes the command.
      #
      # department - The department to destroy
      # current_user - the user performing the action
      def initialize(department, current_user)
        @department = department
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        destroy_department
        broadcast(:ok)
      rescue ActiveRecord::RecordNotDestroyed
        broadcast(:has_spaces)
      end

      private

      attr_reader :current_user

      def destroy_department
        Decidim.traceability.perform_action!(
          "delete",
          @department,
          current_user
        ) do
          @department.destroy!
        end
      end
    end
  end
end
