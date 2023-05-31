# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating an department.
    class CreateDepartment < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # user - A user that performs action
      def initialize(form, user)
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

        create_department
        broadcast(:ok)
      end

      private

      attr_reader :form, :current_user

      # Private: creating department
      #
      # Method creates ActionLog
      #
      # Returns: Department
      def create_department
        Decidim.traceability.create!(
          Decidim::AdminExtended::Department,
          current_user,
          attributes
        )
      end

      # Private: Hash of department attributes
      def attributes
        {
          name: form.name,
          organization: current_user.organization
        }
      end
    end
  end
end
