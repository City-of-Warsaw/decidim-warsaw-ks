# frozen_string_literal: true

Decidim::BlockUserMailer.class_eval do
  layout "mailer"

  def notify(user, justification)
    service = Decidim::CoreExtended::MailTemplateService.new('block_user', user, { reason_for_blocking: justification })
    return unless service.active?

    @user = user
    @body = service.parse_body

    mail(to: user.email, subject: service.parse_subject)
  end
end
