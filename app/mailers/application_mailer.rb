# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Decidim.config.mailer_sender
  layout 'mailer'

  # For testing asset hosts:
  #   ApplicationMailer.test_mail('test email').deliver_now!
  def test_mail(email_to)
    mail(to: email_to, subject: 'Mail testowy', body: 'tresc maila..')
  end
end
