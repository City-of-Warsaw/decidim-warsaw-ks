# frozen_string_literal: true

Decidim::Permissions.class_eval do
  # overwritten method
  # rebuild it - add to it additional conditions
  def permissions
    return permission_action if read_ad_space_action? # custom
    return permission_action unless permission_action.scope == :public

    read_public_pages_action?
    locales_action?
    component_public_action?
    search_scope_action?
    moderation_action? # custom

    return permission_action unless user

    user_manager_permissions
    manage_self_user_action?
    authorization_action?
    follow_action?
    amend_action?
    notification_action?
    conversation_action?
    user_group_action?
    user_group_invitations_action?
    apply_endorsement_permissions if permission_action.subject == :endorsement

    permission_action
  end


  private

  def user_can_preview_component?
    return false if user.nil? || component.participatory_space.nil?
    return false unless component.manifest_name == "surveys" || component.manifest_name == "study_notes"

    return component.participatory_space.user_roles(:admin).pluck(:decidim_user_id).include?(user.id)
  end

  def moderation_action?
    return false unless permission_action.subject == :moderation
    return false unless permission_action.action == :create

    toggle_allow(true)
  end

  def read_ad_space_action?
    return false unless permission_action.subject == :ad_space && permission_action.action == :read

    toggle_allow(user&.has_ad_role?)
    true
  end
end
