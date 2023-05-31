# frozen_string_literal: true

module Decidim
  module CoreExtended
    class TemplatedMailer < Decidim::ApplicationMailer
      include Decidim::EmailChecker

      def notify(action_name, receiver, passed_data)
        service = Decidim::CoreExtended::MailTemplateService.new(action_name, receiver, passed_data)
        return unless service.active?

        email = service.email
        return if email.blank?
        return unless valid_email?(email)

        @body = service.parse_body
        # @organization = resource.organization
        @organization = Decidim::Organization.first

        mail(to: email, subject: service.parse_subject)
      end
    end
  end
end