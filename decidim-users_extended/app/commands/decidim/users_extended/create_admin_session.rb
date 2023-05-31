# frozen_string_literal: true

module Decidim
  module UsersExtended
    # A command with all the business logic when a user publishes a draft project.
    class CreateAdminSession < Rectify::Command
      # Public: Initializes the command.
      #
      # form     - admin sign-in form
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the project is published.
      # - :invalid if the project's author is not the current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless authenticated_with_ad?

        transaction do
          create_login_log
          # role_change_log unless @user.has_ad_role?(ad_role) # to jest dla zmiany roli uzytkownika
        end
        broadcast(:ok, user)
      end

      private

      attr_reader :form
      attr_accessor :user

      # This method should communicate with AD
      # if credentials are valid it assigns ad_role and looks for user in decidim_db
      # if credentials are invalid it returns false
      def authenticated_with_ad?
        if Rails.env.development?
          return @user = Decidim::User.find_by(ad_name: @form.nickname)
        end

        ad_auth_service = Decidim::UsersExtended::AdAuthorizationService.new(form.nickname, form.password)
        if @user = ad_auth_service.call
          true
        else
          false
        end
      end

      # def role_change_log
      #   Decidim.traceability.perform_action!(
      #     :assign_role,
      #     user,
      #     user,
      #     visibility: "admin-only"
      #   ) do
      #     user.assign_ad_role!(ad_role)
      #   end
      # end

      def create_login_log
        Decidim.traceability.perform_action!(
          :login,
          @user,
          @user,
          visibility: "admin-only"
        )
      end

    end
  end
end
