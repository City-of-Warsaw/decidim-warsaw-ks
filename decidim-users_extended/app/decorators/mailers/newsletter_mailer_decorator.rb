# frozen_string_literal: true

Decidim::NewsletterMailer.class_eval do
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