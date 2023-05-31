# frozen_string_literal: true

Decidim::AdminLog::UserPresenter.class_eval do
  private

  def action_string
    case action
    when "grant_id_documents_offline_verification", "invite", "officialize", "remove_from_admin", "show_email", "unofficialize", "block", "unblock", "promote", "transfer"
      "decidim.admin_log.user.#{action}"
    when "user_login", "user_logout"
      # custom - city users
      "decidim.admin_log.user.#{action}"
    when "login", "assign_role", "update_user"
      # custom - ad users
      "decidim.admin_log.user.#{action}"
    else
      super
    end
  end
end
