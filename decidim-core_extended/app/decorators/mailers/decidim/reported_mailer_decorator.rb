# frozen_string_literal: true

Decidim::ReportedMailer.class_eval do
  include Decidim::EmailChecker

  # overwritten method
  # use our mail template service
  def report(user, report)
    with_user(user) do
      Rails.logger.debug { "[ReportedMailer] init method report, before Decidim::CoreExtended::MailTemplateService.new" }

      action_name = "report_notification_to_moderators"
      reportable = report.moderation.reportable
      participatory_space = if report.moderation.participatory_space.is_a?(Decidim::News::Information)
                              nil
                            else
                              report.moderation.participatory_space
                            end
      reported_content = report.moderation.reported_content
      report_reasons = reportable.moderation.reports.pluck(:reason).uniq
      report_details = reportable.moderation.reports.pluck(:details).uniq
      service = Decidim::CoreExtended::MailTemplateService.new(action_name,
                                                               user,
                                                               {
                                                                 resource: reportable,
                                                                 consultation: participatory_space,
                                                                 report_reasons:,
                                                                 reported_content:,
                                                                 report_details:
                                                               })
      return unless service.active?

      email = service.email
      return if email.blank?
      return unless valid_email?(email)

      @body = service.parse_body
      @organization = Decidim::Organization.first
      @footer = service.footer

      mail(to: email, subject: service.parse_subject)

      Rails.logger.debug do
        <<~LOG
          [ReportedMailer] Mail has been sent:
            Action name: #{action_name}
            Receiver: #{user} (email: #{email})
            Subject: #{service.parse_subject}
        LOG
      end
    end
  end

  # overwritten method
  # use our mail template service
  def hide(user, report)
    with_user(user) do
      Rails.logger.debug { "[ReportedMailer] init method hide, before Decidim::CoreExtended::MailTemplateService.new" }

      action_name = "hide_notification_to_moderators"
      reportable = report.moderation.reportable
      participatory_space = if report.moderation.participatory_space.is_a?(Decidim::News::Information)
                              nil
                            else
                              report.moderation.participatory_space
                            end
      reported_content = report.moderation.reported_content
      report_details = reportable.moderation.reports.pluck(:details).uniq
      service = Decidim::CoreExtended::MailTemplateService.new(action_name,
                                                               user,
                                                               {
                                                                 resource: reportable,
                                                                 consultation: participatory_space,
                                                                 reported_content:,
                                                                 report_details:
                                                               })
      return unless service.active?

      email = service.email
      return if email.blank?
      return unless valid_email?(email)

      @body = service.parse_body
      @organization = Decidim::Organization.first
      @footer = service.footer

      mail(to: email, subject: service.parse_subject)

      Rails.logger.debug do
        <<~LOG
          [ReportedMailer] Mail has been sent:
            Action name: #{action_name}
            Receiver: #{user} (email: #{email})
            Subject: #{service.parse_subject}
        LOG
      end
    end
  end
end
