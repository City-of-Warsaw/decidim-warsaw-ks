# frozen_string_literal: true

Decidim::Admin::DeliverNewsletter.class_eval do
  # overwritten method
  # !@user.admin? switched to !@user.ad_admin?
  def call
    @newsletter.with_lock do
      return broadcast(:invalid) if @form.send_to_all_users && !form.current_user.ad_admin?
      return broadcast(:invalid) unless @form.valid?
      return broadcast(:invalid) if @newsletter.sent?
      return broadcast(:no_recipients) if recipients.blank?

      send_newsletter!
    end

    broadcast(:ok, @newsletter)
  end
end
