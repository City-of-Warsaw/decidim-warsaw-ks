# frozen_string_literal: true

Decidim::ActionLog.class_eval do
  scope :sort_by_admin_log_select_param, ->(value) {
    case value
    when "created_at_asc"
      order(created_at: :asc)
    when "created_at_desc"
      order(created_at: :desc)
    else
      order(created_at: :desc)
    end
  }

  # overwritten method
  # add sort_by
  def self.ransackable_scopes(auth_object = nil)
    base = [:with_resource_type]
    return base unless auth_object&.admin?

    # Add extra scopes for admins for the admin panel searches
    base + [:with_participatory_space, :sort_by_admin_log_select_param]
  end
end
