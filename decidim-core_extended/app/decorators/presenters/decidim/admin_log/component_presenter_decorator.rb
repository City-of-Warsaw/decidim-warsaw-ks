# frozen_string_literal: true

# OVERWRITTEN DECIDIM CLASS
Decidim::AdminLog::ComponentPresenter.class_eval do
  private

  # Overwritten Decidim method
  #
  # Added missing action for AI:
  #
  # - disable_ai
  # - enable_ai
  def action_string
    case action
    when "export_component", "disable_ai", "enable_ai"
      "decidim.admin_log.component.#{action}"
    when "create", "delete", "publish", "unpublish", "update_permissions"
      generate_action_string(action)
    else
      super
    end
  end
end
