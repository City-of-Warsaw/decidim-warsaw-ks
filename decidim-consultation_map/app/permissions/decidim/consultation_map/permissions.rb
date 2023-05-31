# frozen_string_literal: true

module Decidim
  module ConsultationMap
    class Permissions < Decidim::DefaultPermissions
      def permissions
        # return permission_action unless permission_action.subject == :expert_questions

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::ConsultationMap::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        return permission_action if permission_action.scope != :public

        allow!
        permission_action
      end
    end
  end
end
