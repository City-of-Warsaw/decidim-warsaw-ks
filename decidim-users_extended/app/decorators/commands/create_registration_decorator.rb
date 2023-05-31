# frozen_string_literal: true

Decidim::CreateRegistration.class_eval do

  private

  # overwritten attributes for creating user
  # added custom attributes
  def create_user
    @user = Decidim::User.create!(
      email: form.email,
      name: form.name,
      nickname: form.nickname,
      password: form.password,
      password_confirmation: form.password_confirmation,
      organization: form.current_organization,
      tos_agreement: form.tos_agreement,
      email_on_notification: true,
      accepted_tos_version: form.current_organization.tos_version,
      locale: form.current_locale,
      # custom - statistic data
      gender: form.gender,
      birth_year: form.birth_year,
      district: scope,
      # custom - notifications
      # email_on_notification: form.email_on_notification, # Decidim default
      newsletter_notifications_at: newsletter_at,
      # notification_types: form.notification_types, # Decidim default - copied from interests page
      notifications_from_neighbourhood: form.notifications_from_neighbourhood,
      follow_ngo: form.follow_ngo,
      extended_data: chosen_interests,
      zip_code: form.zip_code
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
