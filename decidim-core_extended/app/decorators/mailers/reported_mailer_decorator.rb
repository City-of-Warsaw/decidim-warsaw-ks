# frozen_string_literal: true

Decidim::ReportedMailer.class_eval do
  include Decidim::EmailChecker

  # Notify author about report of his content
  # komentarz moze byc zgloszony tez w aktualnosci
  def notify_author(report)
    @report = report
    @reportable = @report.moderation.reportable
    # if @report.moderation.participatory_space.is_a? Decidim::News::Information
    # else
    # end
    @organization = @report.moderation.organization
    @participatory_space = @report.moderation.participatory_space # moze byc Decidim::News::Information
    @author = @reportable.try(:creator_identity) || @reportable.try(:author)

    return if @author.try(:email_on_notification) == false

    action_name = 'resource_was_reported'
    service = Decidim::CoreExtended::MailTemplateService.new(action_name,
                                                             @author,
                                                             {
                                                               resource: @reportable,
                                                               consultation: @participatory_space
                                                             })
    return unless service.active?
    return unless valid_email?(service.email)

    @body = service.parse_body
    mail(to: service.email, subject: service.parsed_subject)
  end

  # Notify moderator about reported content
  def notify_moderator(moderator, report)
    @report = report
    @reportable = @report.moderation.reportable
    @organization = @report.moderation.organization
    @participatory_space = @report.moderation.participatory_space # moze byc Decidim::News::Information
    action_name = 'report_notification_to_moderators'
    service = Decidim::CoreExtended::MailTemplateService.new(action_name,
                                                             moderator,
                                                             {
                                                               resource: @reportable,
                                                               consultation: @participatory_space,
                                                               report_reasons: @reportable.moderation.reports.pluck(:reason).uniq,
                                                               reported_content: @report.moderation.reported_content
                                                             })
    return unless service.active?

    @body = service.parse_body
    mail(to: service.email, subject: service.parsed_subject)
  end

  def hide_notification_to_author(reportable)
    report_reasons = reportable.moderation.reports.pluck(:reason).uniq
    if reportable.is_a?(Decidim::Comments::Comment)
      action_name = 'comment_hidden'
      passed_data = {
        author: reportable.author,
        report_reasons: report_reasons,
        comment: reportable,
        resource_content: reportable.body['pl']
        # TODO: normalnie pobierane jest z eventu
        # resource_content: translated_attribute(@resource[@resource.reported_attributes.first]).truncate(100, separator: " ")
      }
    else
      action_name = 'remark_hidden'
      passed_data = {
        author: reportable.author,
        report_reasons: report_reasons,
        remark: reportable,
        resource_content: reportable.body
      }
    end

    service = Decidim::CoreExtended::MailTemplateService.new(action_name, reportable.author, passed_data)

    return unless service.active?
    return unless valid_email?(reportable.author.email)

    @organization = reportable.organization
    @body = service.parse_body
    mail(to: reportable.author.email, subject: service.parse_subject)
  end

  # TODO: mail dla moderatorow + szablon
  # def report(user, report)
  #   with_user(user) do
  #     @report = report
  #     @reportable = @report.moderation.reportable
  #     @participatory_space = @report.moderation.participatory_space
  #     @organization = user.organization
  #     @user = user
  #     @author = @reportable.try(:creator_identity) || @reportable.try(:author)
  #     @original_language = original_language(@reportable)
  #
  #     action_name = 'resource_was_reported'
  #     service = Decidim::CoreExtended::MailTemplateService.new(action_name, @user, { resource: @participatory_space, consultation: @participatory_space })
  #     return unless service.active?
  #
  #     @body = service.parse_body
  #
  #     # subject = I18n.t("report.subject", scope: "decidim.reported_mailer")
  #     subject = service.parsed_subject
  #     mail(to: user.email, subject: subject)
  #   end
  # end

end