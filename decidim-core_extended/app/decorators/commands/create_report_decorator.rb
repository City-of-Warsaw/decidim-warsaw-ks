# frozen_string_literal: true

Decidim::CreateReport.class_eval do
  # overwritten method
  # add context to tool
  def initialize(form, reportable)
    @form = form
    @reportable = reportable
    @tool = Decidim::ModerationTools.new(reportable, current_user, context: { details: form.details })
  end

  private

  # overwritten method
  # use all admins rather than only process moderators
  def send_report_notification_to_moderators
    admins = Decidim::User.admins.not_blocked.confirmed.where(email_on_notification: true).to_a

    admins.each do |admin|
      next unless admin.email_on_moderations

      Decidim::ReportedMailer.report(admin, @report).deliver_later
    end
  end

  # overwritten method
  # use all admins rather than only process moderators
  def send_hide_notification_to_moderators
    admins = Decidim::User.admins.not_blocked.confirmed.where(email_on_notification: true).to_a

    admins.each do |admin|
      next unless admin.email_on_moderations

      Decidim::ReportedMailer.hide(admin, @report).deliver_later
    end
  end
end
