# frozen_string_literal: true

# OVERWRITTEN DECIDIM CLASS
Decidim::AdminLog::ModerationPresenter.class_eval do
  private

  # Overwritten Decidim method
  #
  # Added missing cation for moderation:
  # - unhide
  def action_string
    case action
    when "hide", "unhide", "unreport"
      "decidim.admin_log.moderation.#{action}"
    else
      super
    end
  end
end