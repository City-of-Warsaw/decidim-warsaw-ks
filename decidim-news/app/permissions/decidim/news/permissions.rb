# frozen_string_literal: true

module Decidim
  module News
    class Permissions < Decidim::DefaultPermissions
      def permissions
        # permission to edit link for admin on public information page
        if permission_action.action == :read && permission_action.subject == :admin_dashboard
          toggle_allow(user && user.ad_admin?)
          return permission_action
        end

        return permission_action if permission_action.subject != :information

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::News::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        case permission_action.action
        when :index
          allow!
        when :show
          toggle_allow(can_show_information?)
        end

        permission_action
      end

      private

      def information
        @information ||= context.fetch(:information, nil)
      end

      def can_show_information?
        return unless permission_action.action == :show

        information.published? || user && (user.ad_admin? || user.ad_coordinator?)
      end
    end
  end
end
