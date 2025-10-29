# frozen_string_literal: true

module Decidim
  module CoreExtended
    class TemplatedMailer < Decidim::ApplicationMailer
      include Decidim::EmailChecker

      def notify(action_name, receiver, passed_data)
        Rails.logger.debug { "[TemplatedMailer] init method notify, before Decidim::CoreExtended::MailTemplateService.new" }

        service = Decidim::CoreExtended::MailTemplateService.new(action_name, receiver, passed_data)
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
            [TemplatedMailer] Mail has been sent:
              Action name: #{action_name}
              Receiver: #{receiver} (email: #{email})
              Subject: #{service.parse_subject}
              Passed data: #{passed_data.inspect}
          LOG
        end
      end
    end
  end
end
