# frozen_string_literal: true

# OVERWRITTEN DECIDIM COMMAND
# An update object used to update interests for the user's interests
# Class has been provided with attributes for adding more personal information about current user, to /account
#
# Private: assing correct data to added variables
# Command has been expanded with:
# - additional interests
Decidim::UpdateUserInterests.class_eval do
  private

  # overwritten method - expanded with additonal interests
  def update_interests
    @user.extended_data ||= {}
    @user.extended_data["interested_scopes"] = selected_scopes_ids
    @user.extended_data["interested_tags"] = selected_tags_ids

    @user.follow_ngo = @form.follow_ngo
    @user.notifications_from_neighbourhood = @form.notifications_from_neighbourhood
    @user.zip_code = @form.zip_code
  end

  # custom method added
  def selected_tags_ids
    @form.tags_ids.reject(&:blank?)
  end

  def selected_scopes_ids
    @form.scopes_ids.reject(&:blank?)
  end
end