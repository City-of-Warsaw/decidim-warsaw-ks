# frozen_string_literal: true

module Decidim
  module GeneralPlanRequests
    module Admin
      class Permissions < Decidim::Admin::Permissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          allowed_to_manage_general_plan_requests_action?
          allowed_to_register_general_plan_request_to_signum_action?

          permission_action
        end

        private

        def allowed_to_manage_general_plan_requests_action?
          return unless permission_action.subject == :general_plan_requests
          return unless permission_action.action == :manage

          toggle_allow(
            user.ad_admin? ||
              user.ad_coordinator? ||
              has_role_in_space?(:admin) &&
                !current_participatory_space.published?
          )
        end

        def allowed_to_register_general_plan_request_to_signum_action?
          return unless permission_action.subject == :general_plan_request
          return unless permission_action.action == :register_to_signum

          toggle_allow(user.ad_admin? && !current_participatory_space.published?)
        end
      end
    end
  end
end
