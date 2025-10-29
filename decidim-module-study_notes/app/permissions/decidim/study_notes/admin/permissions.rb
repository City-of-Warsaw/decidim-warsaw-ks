# frozen_string_literal: true

module Decidim
  module StudyNotes
    module Admin
      class Permissions < Decidim::Admin::Permissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          allowed_manage_study_notes_action?
          allowed_manage_map_backgrounds_action?
          allowed_manage_legend_items_action?

          permission_action
        end

        private

        #  adding map_backgrouns, categories, legend_items
        def allowed_manage_study_notes_action?
          return unless permission_action.subject == :study_notes
          return unless permission_action.action == :manage

          toggle_allow(user.ad_admin? || user.ad_coordinator?)
        end

        def allowed_manage_map_backgrounds_action?
          return unless permission_action.subject == :map_backgrounds
          return unless permission_action.action == :manage

          toggle_allow(user.ad_admin? || user.ad_coordinator? )
        end

        def allowed_manage_legend_items_action?
          return unless permission_action.subject == :legend_items
          return unless permission_action.action == :manage

          toggle_allow(user.ad_admin? || user.ad_coordinator?)
        end

      end
    end
  end
end
