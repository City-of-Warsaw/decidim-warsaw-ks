# frozen_string_literal: true

Decidim::NewsletterMailer.class_eval do

  def newsletter(user, newsletter, preview = nil)
    return if user.email.blank?

    @organization = user.organization
    @newsletter = newsletter
    @user = user
    @preview = preview

    @custom_url_for_mail_root =
      if @preview
        "#"
      elsif Decidim.config.track_newsletter_links
        custom_url_for_mail_root(@organization, @newsletter.id)
      end
    @encrypted_token = Decidim::NewsletterEncryptor.sent_at_encrypted(@user.id, @user.class.to_s, 'newsletter')

    with_user(user) do
      uninterpolated_subject =
        @newsletter.subject[I18n.locale.to_s].presence || @newsletter.subject[@organization.default_locale]

      @subject = parse_interpolations(uninterpolated_subject, user, @newsletter.id)

      mail(to: "#{user.name} <#{user.email}>", subject: @subject)
    end
  end

  def newsletter_without_account(email, newsletter)
    @newsletter = newsletter
    @organization = Decidim::Organization.first
    @subject = @newsletter.subject[I18n.locale.to_s].presence || @newsletter.subject[@organization.default_locale]

    mail(to: "#{email} <#{email}>", subject: @subject)
  end

  private

  # private method
  # method that sets a second set of smtp settings for sendinh newsletter
  # if it was saved in Organization
  def set_smtp
    return if @organization.nil? || @organization.newsletter_smtp_settings.blank? || @organization.smtp_settings.blank?

    if @organization.newsletter_smtp_settings&.any?
      mail.from = @organization.newsletter_smtp_settings["from"].presence || mail.from
      mail.reply_to = mail.from || Decidim.config.mailer_reply
      mail.delivery_method.settings.merge!(
        address: @organization.newsletter_smtp_settings["address"],
        port: @organization.newsletter_smtp_settings["port"],
        user_name: @organization.newsletter_smtp_settings["user_name"],
        password: Decidim::AttributeEncryptor.decrypt(@organization.newsletter_smtp_settings["encrypted_password"])
      ) { |_k, o, v| v.presence || o }.reject! { |_k, v| v.blank? }
    else
      super
    end
  end
end