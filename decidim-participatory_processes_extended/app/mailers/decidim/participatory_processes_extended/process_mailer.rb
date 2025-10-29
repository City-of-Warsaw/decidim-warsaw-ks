# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    class ProcessMailer < Decidim::ApplicationMailer
      include Decidim::EmailChecker
      include Decidim::GeneralPlanRequests::PdfAnonymisation

      # Actions:
      # - two_days_till_consultations_end
      def notify_about_consultation(action_name, resource, receiver)
        passed_data = { resource: resource, consultation: resource }

        # Add result body only if there is published effect
        first_published_result = resource.results.published.sorted_by_weight.first
        passed_data[:result_body] = first_published_result.body if first_published_result&.body.present?

        # Add report_description only if there are published effects or report
        # Effects are always after the report - therefore report will be present if there will be effects
        if %w[report effects].include?(resource.consultation_status)
          passed_data[:report_description] = resource.report_description
        end
        
        service = Decidim::CoreExtended::MailTemplateService.new(action_name, receiver, passed_data)
        return unless service.active?

        email = service.email
        return if email.blank?
        return unless valid_email?(email)

        @body = service.parse_body
        @organization = resource.organization
        @footer = service.footer

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
        @footer = service.footer

        mail(to: email, subject: service.parse_subject)
      end

      def confirmation_about_study_note_user(action_name, resource, receiver)
        service = Decidim::CoreExtended::MailTemplateService.new(action_name, receiver, {})
        return unless service.active?

        email = service.email
        return if email.blank?
        return unless valid_email?(email)
        @footer = service.footer

        @body = service.parse_body
        @organization = resource.organization
        attachments["#{resource.pdf_name}.pdf"] = Decidim::PdfGeneratorService.new.save_to_pdf(resource)
        mail(to: email, subject: service.parse_subject)
      end

      def confirmation_about_general_plan_request(action_name, resource, receiver, anonymize_pdf)
        service = Decidim::CoreExtended::MailTemplateService.new(action_name, receiver, {})
        return unless service.active?

        email = service.email
        return if email.blank?
        return unless valid_email?(email)

        @body = service.parse_body
        @organization = resource.organization
        @footer = service.footer

        normal_pdf = Decidim::PdfGeneratorService.new.save_to_pdf(resource)
        attachments["#{resource.pdf_name}.pdf"] = normal_pdf

        if anonymize_pdf
          anonymize_general_plan_request(resource)
          anonymized_pdf = Decidim::PdfGeneratorService.new.save_to_pdf(resource)
          attachments["#{resource.anonymized_pdf_name}.pdf"] = anonymized_pdf
        end

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
        @footer = service.footer

        mail(to: email, subject: service.parse_subject)
      end
    end
  end
end
