# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command to update the admin user.
    class UpdateAdminUser < Decidim::Command
      # Public: Initializes the command.
      #
      # admin_user - The admin user to be updated.
      # current_user - The user performing the action
      def initialize(form, admin_user, current_user)
        @form = form
        @admin_user = admin_user
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_admin_user
        broadcast(:ok)
      end

      private

      attr_reader :form, :admin_user, :current_user

      # Private: updating admin user
      #
      # Method creates ActionLog
      #
      # Returns: admin user
      def update_admin_user
        Decidim.traceability.perform_action!(
          "update_user_editorial",
          user,
          current_user
        ) do
          user.update!(editorial: form.editorial)
        end
      end
    end
  end
end
