# frozen_string_literal: true

Decidim::UpdateUserInterests.class_eval do
  private

  # overwritten method
  # add attrs
  def update_interests
    current_user.extended_data ||= {}
    current_user.extended_data["interested_scopes"] = selected_scopes_ids

    # custom attrs
    current_user.extended_data["interested_tags"] = selected_tags_ids
    current_user.follow_ngo = @form.follow_ngo
    current_user.notifications_from_neighbourhood = @form.notifications_from_neighbourhood
    current_user.zip_code = @form.zip_code
    current_user.newsletter_notifications_at = @form.newsletter_notifications_at
    current_user.email_on_notification = @form.email_on_notification
  end

  def selected_tags_ids
    @form.tags_ids.reject(&:blank?)
  end

  # overwritten method
  # rebuild it completely
  def selected_scopes_ids
    scopes = @form.scopes_ids.reject(&:blank?)
    scopes += [Decidim::Scope.citywide.id] if @form.scope_citywide
    scopes
  end
end
