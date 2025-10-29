# frozen_string_literal: true

Decidim::AdminLog::UserPresenter.class_eval do
  private

  # overwritten method
  # add more actions
  def action_string
    case action
    when "grant_id_documents_offline_verification", "invite", "officialize", "remove_from_admin", "show_email", "unofficialize", "block", "unblock", "promote", "transfer"
      "decidim.admin_log.user.#{action}"
      # custom:
    when "user_login", "user_logout", "login", "assign_role", "update_user", "update_user_editorial"
      "decidim.admin_log.user.#{action}"
    when "deactivate_ad_user", "activate_ad_user", "auto_deactivate_ad_user", "auto_activate_ad_user","admins_list_export"
      "decidim.admin_log.user.#{action}"
    else
      super
    end
  end
end
