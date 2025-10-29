# frozen_string_literal: true

module Interceptors
  # Prevent sending emails to users from @example.com domain
  # If there is defined REDIRECT_MAILS_TO in ENV vars, all emails will be redirected
  class StagingEmailInterceptor
    def self.delivering_email(mail)
      return unless redirect_to_address

      unless should_be_deliver?(mail)
        mail.perform_deliveries = false
        Rails.logger.debug "Interceptor prevented sending mail #{mail.inspect}!"
      end

      if redirect_to_address
        original_to = mail.header[:to].to_s
        original_subject = mail.header[:subject].to_s

        mail.to = redirect_to_address
        mail.subject = "#{original_subject} [originally to: #{original_to}]"
        Rails.logger.debug "Interceptor redirect mail to #{mail.to}!"
      end

    end

    def self.should_be_deliver?(mail)
      mail.header[:to].to_s.include?("atende.pl")
    end

    def self.redirect_to_address
      ENV.fetch('REDIRECT_MAILS_TO') { nil }
    end
  end
end