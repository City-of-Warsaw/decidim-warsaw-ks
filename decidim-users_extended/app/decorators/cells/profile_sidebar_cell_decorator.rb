# frozen_string_literal: true

Decidim::ProfileSidebarCell.class_eval do
  def show
    render :show_new
  end

  private

  # Overwritten decidim method
  #
  # Permanently disallowing contacting with users.
  def can_contact_user?
    false
  end
end