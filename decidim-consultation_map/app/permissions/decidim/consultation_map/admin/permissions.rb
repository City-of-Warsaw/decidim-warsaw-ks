# frozen_string_literal: true

module Decidim
  module ConsultationMap
    module Admin
      class Permissions < Decidim::Admin::Permissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          # allowed_component_action?
          allowed_remark_action?

          allowed_publishing_action? # not used currently

          permission_action
        end

        private

        def remark
          @remark ||= context.fetch(:remark, nil)
        end

        def allowed_remark_action?
          return unless permission_action.subject == :map_remark
          return if permission_action.action == :publish

          toggle_allow((user.ad_admin? || has_role_in_space?(:admin)) && admin_terms_accepted?)
        end

        def allowed_publishing_action?
          return unless permission_action.action == :publish

          toggle_allow(user.ad_admin? && admin_terms_accepted?)
        end
      end
    end
  end
end
