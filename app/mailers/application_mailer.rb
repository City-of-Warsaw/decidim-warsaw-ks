class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  # For testing asset hosts:
  #   ApplicationMailer.test_mail('test email').deliver_now!
  def test_mail(email_to)
    mail(to: email_to, subject: 'Mail testowy', body: 'tresc maila..')
  end
end
