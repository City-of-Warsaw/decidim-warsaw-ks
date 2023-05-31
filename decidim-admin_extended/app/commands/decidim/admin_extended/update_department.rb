# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating an department.
    class UpdateDepartment < Rectify::Command
      # Public: Initializes the command.
      #
      # department - The Department to update
      # form - A form object with the params.
      # user - A user that performs action
      def initialize(department, form, user)
        @department = department
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

        update_department
        broadcast(:ok)
      end

      private

      attr_reader :form, :current_user

      # Private: updating department
      #
      # Method creates ActionLog
      #
      # Returns: Department
      def update_department
        Decidim.traceability.update!(
          @department,
          current_user,
          attributes
        )
      end

      # Private: Hash of department attributes
      def attributes
        {
          name: form.name
        }
      end
    end
  end
end
