# frozen_string_literal: true

Decidim::ParticipatoryProcesses::Permissions.class_eval do
  def permissions
    user_can_enter_processes_space_area?
    user_can_enter_process_groups_space_area?

    return permission_action if process && !process.is_a?(Decidim::ParticipatoryProcess)

    if read_admin_dashboard_action?
      user_can_read_admin_dashboard?
      return permission_action
    end

    if permission_action.scope == :public
      public_list_processes_action?
      public_list_process_groups_action?
      public_read_process_group_action?
      public_read_process_action?
      public_report_content_action?
      return permission_action
    end

    return permission_action unless user

    if !has_manageable_processes? && !user.ad_admin?
      disallow!
      return permission_action
    end
    return permission_action unless permission_action.scope == :admin

    valid_process_group_action?

    user_can_read_process_list?
    user_can_read_current_process?
    user_can_create_process?
    user_can_update_process?
    user_can_publish_process?

    # org admins and space admins can do everything in the admin section
    org_admin_action?

    return permission_action unless process

    moderator_action?
    # collaborator_action?
    # valuator_action?
    process_admin_action?

    permission_action
  end


  private

  def has_manageable_processes?(role: :any)
    return unless user
    # for letting users with ad_roles get past to their specyfic permissions
    return true if user.has_ad_role?

    participatory_processes_with_role_privileges(role).any?
  end

  # Overwritten. Process groups area is hidden from menu
  def user_can_enter_process_groups_space_area?
  end

  # Only organization admins can create a process
  # Customization: ad_admin && ad_coordinator can create process
  def user_can_create_process?
    return unless permission_action.action == :create &&
                  permission_action.subject == :process

    toggle_allow(user.ad_admin? || user.ad_coordinator?)
  end

  def user_can_read_current_process?
    return unless read_process_list_permission_action?
    return if permission_action.subject == :process_list

    # Tu testuje wybrany proces
    toggle_allow(user.ad_admin? || can_manage_process?(role: :admin) || is_user_this_space_expert?)
  end

  # Customization: ad_admin && admin can publish process
  def user_can_publish_process?
    return unless permission_action.action == :publish &&
                  permission_action.subject == :process

    toggle_allow(user.ad_admin?)
  end

  # Customization: ad_admin && admin can publish process, expert can not
  def user_can_update_process?
    return unless permission_action.action == :update &&
                  permission_action.subject == :process

    toggle_allow(user.ad_admin? || can_manage_process?(role: :admin))
  end

  def can_manage_process?(role: :any)
    return unless user

    user.ad_admin? || user.ad_coordinator? && participatory_processes_with_role_privileges(role).include?(current_participatory_space)
  end

  def process_admin_action?
    return if user.ad_admin?
    return unless can_manage_process?(role: :admin)
    return disallow! if permission_action.action == :create &&
                        permission_action.subject == :process
    return disallow! if permission_action.action == :publish &&
                        permission_action.subject == :process

    is_allowed = [
      :attachment,
      :attachment_collection,
      :category,
      :component,
      :component_data,
      :moderation,
      :process,
      :process_step,
      :process_user_role,
      # :space_private_user, # not allowed
      :export_space,
      :import
    ].include?(permission_action.subject)
    allow! if is_allowed
  end

  def org_admin_action?
    return unless user.ad_admin?

    is_allowed = [
      :attachment,
      :attachment_collection,
      :category,
      :component,
      :component_data,
      :moderation,
      :process,
      :process_step,
      :process_user_role,
      # :space_private_user,  # not allowed
      :export_space,
      :import,
    ].include?(permission_action.subject)
    allow! if is_allowed
  end

  def current_participatory_space
    @current_participatory_space ||= context.fetch(:current_participatory_space, nil) || context.fetch(:process, nil) || context.fetch(:assembly, nil)
  end

  def is_user_this_space_expert?
    return false unless user
    return false unless current_participatory_space
    return false unless user.ad_expert?

    current_participatory_space.components.where(manifest_name: 'expert_questions').any? &&
      Decidim::ExpertQuestions::Expert.joins(:component)
                                      .where('decidim_components.participatory_space_id = ? AND decidim_components.participatory_space_type = ?', current_participatory_space.id, current_participatory_space.class.name)
                                      .pluck(:decidim_user_id).include?(user.id)
  end
end
