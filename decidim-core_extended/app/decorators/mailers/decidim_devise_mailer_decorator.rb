# frozen_string_literal: true

Decidim::DecidimDeviseMailer.class_eval do

  include Devise::Controllers::UrlHelpers

  # TODO: Mail powitalny po założeniu konta ?
  # activation_success

  def confirmation_instructions(record, token, opts = {})
    @token = token
    activation_link = confirmation_url(record, confirmation_token: @token, host: record.organization.host)
    service = Decidim::CoreExtended::MailTemplateService.new('activation_needed', record, { activation_link: activation_link })
    @body = service.parsed_body

    devise_mail(record, :confirmation_instructions, opts.merge({ subject: service.parsed_subject }))
  end

  def reset_password_instructions(record, token, opts = {})
    @token = token
    password_reset_link = edit_password_url(record, reset_password_token: @token, host: record.organization.host)
    service = Decidim::CoreExtended::MailTemplateService.new('password_change', record, { password_reset_link: password_reset_link })
    @body = service.parsed_body

    devise_mail(record, :reset_password_instructions, opts.merge({ subject: service.parsed_subject }))
  end
end