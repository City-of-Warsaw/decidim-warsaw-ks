# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    class UserMailer < Decidim::ApplicationMailer
      include Decidim::EmailChecker

      def notify_about_answer(user_question)
        service = Decidim::CoreExtended::MailTemplateService.new('expert_answer',
                                                                 user_question.author,
                                                                 {
                                                                   resource: user_question,
                                                                   consultation: user_question.participatory_space,
                                                                   expert: user_question.expert
                                                                 })
        return unless service.active?

        email = service.email
        return if email.blank?
        return unless valid_email?(email)

        @body = service.parse_body
        @organization = user_question.organization

        mail(to: email, subject: service.parse_subject)
      end
    end
  end
end