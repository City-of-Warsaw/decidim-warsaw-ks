# frozen_string_literal: true

Decidim::CreateRegistration.class_eval do
  private

  # overwritten method
  # add custom attrs
  def create_user
    @user = Decidim::User.create!(
      email: form.email,
      name: form.name,
      nickname: form.nickname,
      password: form.password,
      password_updated_at: Time.current,
      organization: form.current_organization,
      tos_agreement: form.tos_agreement,
      newsletter_notifications_at: form.newsletter_at,
      accepted_tos_version: form.current_organization.tos_version,
      locale: form.current_locale,
      # custom - notifications
      email_on_notification: true,
      notifications_from_neighbourhood: form.notifications_from_neighbourhood,
      # custom - interests
      follow_ngo: form.follow_ngo,
      extended_data: chosen_interests,
      zip_code: form.zip_code,
      # custom - stat data
      gender: form.gender,
      birth_year: form.birth_year,
      district: scope
    )
  end

  def chosen_interests
    {
      interested_scopes: form.picked_scopes,
      interested_tags: form.picked_tags
    }
  end

  def scope
    Decidim::Scope.find_by(id: form.district_id)
  end

  def newsletter_at
    return nil unless form.newsletter_notifications

    Time.current
  end
end
