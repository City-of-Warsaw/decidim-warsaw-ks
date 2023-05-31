# frozen_string_literal: true

Decidim::Component.class_eval do

  def users_action_disallowed?
    users_action_end_date.present? && users_action_end_date <= Time.current
  end
end
