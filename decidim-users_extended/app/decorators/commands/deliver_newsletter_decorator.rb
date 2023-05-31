# frozen_string_literal: true

# Delivers the newsletter to its recipients.
Decidim::Admin::DeliverNewsletter.class_eval do

  # OVERWRITTEN DECIDIM METHOD
  # changed permission for sending newsletter:
  # only user with ad_admin permission is allowed to send newsletter to all users
  def call
    @newsletter.with_lock do
      return broadcast(:invalid) if @form.send_to_all_users && !@user.ad_admin? # overwritten line
      return broadcast(:invalid) unless @form.valid?
      return broadcast(:invalid) if @newsletter.sent?
      return broadcast(:no_recipients) if recipients.blank?

      send_newsletter!
    end

    broadcast(:ok, @newsletter)
  end
end