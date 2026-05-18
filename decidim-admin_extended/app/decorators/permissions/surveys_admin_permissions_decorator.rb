# frozen_string_literal: true

Decidim::Surveys::Admin::Permissions.class_eval do
  include Decidim::Admin::PermissionsHelper

  # OVERWRITTEN
  # - update action is for admin, or for coordinator only if process is not published
  # - add permission for :export action
  # - add permission for :export_answers for coordinator
  def permissions
    return permission_action unless user

    return permission_action unless permission_action.scope == :admin

    case permission_action.subject
    when :questionnaire
      case permission_action.action
      when :preview
        toggle_allow(user.ad_admin? || user.ad_coordinator?)
      when :update
        toggle_allow(user.ad_admin? || can_manage_space?(role: :admin))
      when :export
        toggle_allow(user.ad_admin? || can_manage_space?(role: :admin))
      when :export_answers
        toggle_allow(
          user.ad_admin? ||
            user.ad_coordinator? ||
            can_manage_space?(role: :admin) && !current_participatory_space.published?
        )
      end
    when :questionnaire_answers
      case permission_action.action
      when :index, :show, :export_response
        permission_action.allow!
      end
    end

    permission_action
  end

  def can_manage_space?(role: :any)
    return unless user
    return unless current_participatory_space
    return unless user.has_ad_role?

    toggle_allow(user.ad_admin? || has_role_in_space?(:admin))
  end

  def has_role_in_space?(role)
    return false unless user
    return false unless current_participatory_space
    return false unless user.has_ad_role?

    if current_participatory_space.is_a?(Decidim::ParticipatoryProcess)
      participatory_processes_with_role_privileges(role).include?(current_participatory_space)
    end
  end
end
