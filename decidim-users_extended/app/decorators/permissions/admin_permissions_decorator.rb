Decidim::Admin::Permissions.class_eval do
  def permissions
    return permission_action if managed_user_action? # TODO: to block

    unless permission_action.scope == :admin
      read_admin_dashboard_action?
      return permission_action
    end

    unless user
      disallow!
      return permission_action
    end

    if read_assembly_action?
      disallow!
      return permission_action
    end

    if user_manager?
      begin
        allow! if user_manager_permissions.allowed?
      rescue Decidim::PermissionAction::PermissionNotSetError
        nil
      end
    end

    # allow! if can_manage_space?(role: :any)
    can_manage_space?(role: :any)
    can_use_image_editor?
    components_actions?
    read_component_action?
    manage_ai_component_action?
    read_admin_dashboard_action?
    publish_components_action?
    apply_newsletter_permissions_for_admin!
    manage_expert_questions_action?
    manage_custom_proposals_action?

    read_processes_action?
    global_moderation_action?
    read_admin_log_action?
    allowed_repository_action?
    main_page_processes_action?
    results_action?
    banned_words_action?
    hero_sections_action?
    contact_info_positions_action?
    contact_info_groups_action?
    statistics_action_delete?
    statistics_action_edit?
    statistics_action_new?

    if user.ad_admin? && admin_terms_accepted?
      allow! if read_metrics_action?
      allow! if static_page_action?
      allow! if organization_action?
      allow! if user_action?
      disallow! if disallowed_user_action?

      allow! if permission_action.subject == :category
      allow! if permission_action.subject == :participatory_process_reports
      # allow! if permission_action.subject == :component # All actions are checked separately for component permission
      allow! if permission_action.subject == :admin_user && !permission_action.action.in?([:create,:destroy])
      allow! if permission_action.subject == :attachment
      allow! if permission_action.subject == :attachment_collection
      allow! if permission_action.subject == :scope
      allow! if permission_action.subject == :scope_type
      allow! if permission_action.subject == :area
      disallow! if permission_action.subject == :area_type # to hide element
      allow! if permission_action.subject == :user_group
      allow! if permission_action.subject == :officialization
      allow! if permission_action.subject == :moderate_users
      allow! if permission_action.subject == :authorization
      disallow! if permission_action.subject == :authorization_workflow # to hide element
      allow! if permission_action.subject == :static_page_topic
      allow! if permission_action.subject == :help_sections
      allow! if permission_action.subject == :share_token
    end

    permission_action
  end

  private

  # Show Process in menu for all users from AD
  def read_processes_action?
    return unless permission_action.subject == :space_area &&
                  permission_action.action == :enter &&
                  context.fetch(:space_name, nil) == :processes

    toggle_allow(user.has_ad_role?)
  end

  def read_assembly_action?
    return true if permission_action.subject == :space_area &&
                   permission_action.action == :enter &&
                   context.fetch(:space_name, nil) == :assemblies

    # toggle_allow(user.ad_admin? || user.ad_coordinator?)
  end

  def statistics_action_delete?
    return unless permission_action.subject == :statistics && permission_action.action == :delete

    statistic = context.fetch(:statistic, nil)
    return disallow! if !statistic.deletable

    toggle_allow(user.ad_admin?)
  end

  def statistics_action_edit?
    return unless permission_action.subject == :statistics && permission_action.action == :update

    toggle_allow(user.ad_admin?)
  end
  def statistics_action_new?
    return unless permission_action.subject == :statistics && permission_action.action == :new

    toggle_allow(user.ad_admin?)
  end

  def read_admin_dashboard_action?
    return unless permission_action.subject == :admin_dashboard &&
                  permission_action.action == :read

    return user_manager_permissions if user_manager?

    toggle_allow(user.has_ad_role?)
  end

  def read_admin_log_action?
    return unless permission_action.subject == :admin_log &&
                  permission_action.action == :read

    toggle_allow(user.ad_admin?)
  end

  def allowed_repository_action?
    return unless permission_action.subject == :repository

    if permission_action.action == :manage
      toggle_allow(user.has_ad_role? && !user.ad_expert?)
    elsif permission_action.action == :update
      # TODO: uzupelnic, tylko odpowiednio oznaczone pliki mozna aktualizowac
      toggle_allow(user.has_ad_role? && !user.ad_expert?)
    end
  end

  def main_page_processes_action?
    return unless permission_action.subject == :main_page_processes

    toggle_allow(user.ad_admin?)
  end

  def results_action?
    return unless permission_action.subject == :result &&
                  (
                    permission_action.action == :read ||
                    permission_action.action == :create ||
                    permission_action.action == :update ||
                    permission_action.action == :publish ||
                    permission_action.action == :destroy ||
                    permission_action.action == :send_notification
                  )

    if permission_action.action == :publish
      toggle_allow(user.ad_admin? && admin_terms_accepted?)
    else
      toggle_allow((user.ad_admin? || user.ad_coordinator?) && admin_terms_accepted?)
    end
  end

  def banned_words_action?
    return unless permission_action.subject == :banned_words

    toggle_allow(user.ad_admin?)
  end

  def hero_sections_action?
    return unless permission_action.subject == :hero_sections

    toggle_allow(user.ad_admin?)
  end

  def contact_info_positions_action?
    return unless permission_action.subject == :contact_info_position

    toggle_allow(user.ad_admin?)
  end

  def contact_info_groups_action?
    return unless permission_action.subject == :contact_info_group

    toggle_allow(user.ad_admin?)
  end

  def global_moderation_action?
    return unless permission_action.subject == :global_moderation

    toggle_allow(user.has_ad_role? && !user.ad_expert?)
  end

  def managed_user_action?
    return unless user
    return unless permission_action.subject == :managed_user
    return user_manager_permissions if user_manager?
    return unless user.ad_admin?

    case permission_action.action
    when :create
      toggle_allow(!organization.available_authorizations.empty?)
    else
      allow!
    end

    true
  end

  def components_actions?
    return unless permission_action.subject == :component &&
                  (
                    permission_action.action == :create ||
                    permission_action.action == :update ||
                    permission_action.action == :delete ||
                    permission_action.action == :manage ||
                    permission_action.action == :copy
                  )

    if permission_action.action == :manage
      toggle_allow(user.ad_admin? || has_role_in_space?(:admin) || is_user_this_space_expert?)
    else
      toggle_allow(user.ad_admin? || has_role_in_space?(:admin) && !current_participatory_space.published?)
    end
  end

  def read_component_action?
    return unless permission_action.subject == :component &&
                  permission_action.action == :read

    toggle_allow(user.ad_admin? || has_role_in_space?(:admin) || is_user_this_space_expert?)
  end

  def manage_ai_component_action?
    component = context.fetch(:component, nil)
    return unless permission_action.subject == :component &&
                  permission_action.action == :manage_ai_functions && component.present?

    toggle_allow((user.ad_admin? || user.ad_coordinator?) && allowed_ai_features_for_component?(component.manifest_name))
  end

  def manage_expert_questions_action?
    return unless permission_action.subject == :component
    return unless permission_action.action == :manage_expert_questions

    toggle_allow(user.ad_admin? || has_role_in_space?(:admin) && !current_participatory_space.published? || is_user_this_space_expert?)
  end

  def manage_custom_proposals_action?
    return unless permission_action.subject == :component
    return unless permission_action.action == :manage_custom_proposals

    toggle_allow((user.ad_admin? ||
      (user.ad_coordinator? || has_role_in_space?(:admin)) && !current_participatory_space.published?) && admin_terms_accepted?)
  end

  def publish_components_action?
    return unless permission_action.subject == :component &&
                  permission_action.action == :publish

    toggle_allow(user.ad_admin? && admin_terms_accepted?)
  end

  def apply_newsletter_permissions_for_admin!
    return unless admin_terms_accepted?
    return unless permission_action.subject == :newsletter

    toggle_allow(user.ad_admin?)
  end


  # from Decidim::Admin::Permissions
  def can_manage_space?(role: :any)
    return unless user
    return unless current_participatory_space
    return unless user.has_ad_role?
    return unless (permission_action.subject == :process && permission_action.subject == :assembly)

    toggle_allow(user.ad_admin? || has_role_in_space?(:admin))
  end

  def has_role_in_space?(role)
    return false unless user
    return false unless current_participatory_space
    return false unless user.has_ad_role?
    return if is_user_this_space_expert?

    if current_participatory_space.is_a?(Decidim::ParticipatoryProcess)
      participatory_processes_with_role_privileges(role).include?(current_participatory_space)
    elsif current_participatory_space.is_a?(Decidim::Assembly)
      assemblies_with_role_privileges(role).include?(current_participatory_space)
    end
  end

  # def exeption_for_expert_question_component?
  #   (permission_action.subject == :component) &&
  #           (permission_action.action == :read) &&
  #
  # end

  def is_user_this_space_expert?
    return false unless user
    return false unless current_participatory_space
    return false unless user.ad_expert?

    current_participatory_space.components.where(manifest_name: 'expert_questions').any? &&
      Decidim::ExpertQuestions::Expert.joins(:component)
      .where('decidim_components.participatory_space_id = ? AND decidim_components.participatory_space_type = ?', current_participatory_space.id, current_participatory_space.class.name)
      .pluck(:decidim_user_id).include?(user.id)
  end

  # Returns a collection of Participatory processes where the given user has the
  # specific role privilege.
  def participatory_processes_with_role_privileges(role)
    Decidim::ParticipatoryProcessesWithUserRole.for(user, role)
  end

  def assemblies_with_role_privileges(role)
    Decidim::Assemblies::AssembliesWithUserRole.for(user, role)
  end

  def current_participatory_space
    @current_participatory_space ||= context.fetch(:current_participatory_space, nil) || context.fetch(:process, nil) || context.fetch(:assembly, nil)
  end

  def component
    @component ||= context.fetch(:current_component, nil)
  end

  def user_action?
    return unless permission_action.subject == :user

    subject_user = context.fetch(:user, nil)

    case permission_action.action
    when :promote
      subject_user.managed? && Decidim::ImpersonationLog.active.where(admin: user).empty?
    when :destroy
      subject_user != user
    else
      true
    end
  end

  def allowed_ai_features_for_component?(manifest_name)
    ["surveys"].include?(manifest_name)
  end

  def disallowed_user_action?
    return unless [:impersonatable_user].include?(permission_action.subject)
  end
end
