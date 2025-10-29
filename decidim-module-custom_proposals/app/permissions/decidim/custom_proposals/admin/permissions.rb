# frozen_string_literal: true

module Decidim
  module CustomProposals
    module Admin
      class Permissions < Decidim::Admin::Permissions
        include Decidim::Admin::PermissionsHelper

        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          allowed_custom_proposals_action?

          permission_action
        end

        private

        def custom_proposal
          @custom_proposal ||= context.fetch(:custom_proposal, nil)
        end

        def allowed_custom_proposals_action?
          return unless permission_action.subject == :custom_proposal

          case permission_action.action
          when :read
            toggle_allow((user.ad_admin? || user.ad_coordinator? || has_role_in_space?(:admin)) && admin_terms_accepted?)
          when :create, :update, :destroy
            toggle_allow(user.ad_admin? || is_coordinator_in_space? && !current_participatory_space.published?)
          end
        end
      end
    end
  end
end
