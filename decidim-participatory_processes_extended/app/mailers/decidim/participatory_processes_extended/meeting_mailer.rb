# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    class MeetingMailer < Decidim::ApplicationMailer
      include Decidim::EmailChecker

      def notify(action_name, meeting, receiver)
        service = Decidim::CoreExtended::MailTemplateService.new(action_name,
                                                                 receiver,
                                                                 {
                                                                   resource: meeting,
                                                                   consultation: meeting.participatory_space
                                                                 })
        return unless service.active?

        email = service.email
        return if email.blank?
        return unless valid_email?(email)

        @body = service.parse_body
        @organization = meeting.organization

        mail(to: email, subject: service.parse_subject)
      end
    end
  end
end
