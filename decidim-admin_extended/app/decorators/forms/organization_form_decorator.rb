# frozen_string_literal: true

Decidim::Admin::OrganizationForm.class_eval do

  # Public method that overwrites user_groups_enabled with false value.
  # This project does not use user_groups
  def user_groups_enabled
    false
  end
end