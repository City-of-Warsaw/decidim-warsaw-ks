# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    class ProcessMailer < Decidim::ApplicationMailer
      include Decidim::EmailChecker

      # Actions:
      # - two_days_till_consultations_end
      def notify_about_consultation(action_name, resource, receiver)
        service = Decidim::CoreExtended::MailTemplateService.new(action_name, receiver, { resource: resource, consultation: resource })
        return unless service.active?

        email = service.email
        return if email.blank?
        return unless valid_email?(email)

        @body = service.parse_body
        @organization = resource.organization

        mail(to: email, subject: service.parse_subject)
      end

      # notification after component is published
      # resource - Decidim::Component
      def component_published(action_name, resource, receiver)
        service = Decidim::CoreExtended::MailTemplateService.new(action_name, receiver, { resource: resource, consultation: resource.participatory_space })
        return unless service.active?

        email = service.email
        return if email.blank?
        return unless valid_email?(email)

        @body = service.parse_body
        @organization = resource.organization

        mail(to: email, subject: service.parse_subject)
      end

      def confirmation_about_study_note_user(action_name, resource, receiver)
        service = Decidim::CoreExtended::MailTemplateService.new(action_name, receiver,{})
        return unless service.active?
        email = service.email
        return if email.blank?
        return unless valid_email?(email)

        @body = service.parse_body
        @organization = resource.organization
        attachments["#{resource.id}_potwierdzenie.pdf"] = Decidim::PdfGeneratorService.new.save_study_note_to_pdf(resource)
        mail(to: email, subject: service.parse_subject)
      end

      def notify_about_step(action_name, resource, receiver)
        service = Decidim::CoreExtended::MailTemplateService.new(action_name,
                                                                 receiver,
                                                                 {
                                                                   step: resource,
                                                                   consultation: resource.participatory_process
                                                                 })
        return unless service.active?

        email = service.email
        return if email.blank?
        return unless valid_email?(email)

        @body = service.parse_body
        @organization = resource.organization

        mail(to: email, subject: service.parse_subject)
      end

      # - resource - Decidim::Proposals::Proposal
      def new_comment_to_proposal(action_name, resource, receiver)
        service = Decidim::CoreExtended::MailTemplateService.new(action_name,
                                                                 receiver, {
                                                                   consultation: resource.participatory_space,
                                                                   resource: resource
                                                                 })
        return unless service.active?

        email = service.email
        return if email.blank?
        return unless valid_email?(email)

        @body = service.parse_body
        @organization = resource.organization

        mail(to: email, subject: service.parse_subject)
      end

      def new_comment_to_remark(action_name, resource, receiver)
        service = Decidim::CoreExtended::MailTemplateService.new(action_name,
                                                                 receiver, {
                                                                   consultation: resource.participatory_space,
                                                                   resource: resource
                                                                 })
        return unless service.active?

        email = service.email
        return if email.blank?
        return unless valid_email?(email)

        @body = service.parse_body
        @organization = resource.organization

        mail(to: email, subject: service.parse_subject)
      end

      # send mail if Expert is published
      def expert_published(action_name, resource, receiver)
        service = Decidim::CoreExtended::MailTemplateService.new(action_name,
                                                                 receiver, {
                                                                   resource: resource.participatory_space,
                                                                   expert: resource,
                                                                   consultation: resource.participatory_space
                                                                 })
        return unless service.active?

        email = service.email
        return if email.blank?
        return unless valid_email?(email)

        @body = service.parse_body
        @organization = resource.organization

        mail(to: email, subject: service.parse_subject)
      end

    end
  end
end
