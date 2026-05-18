# frozen_string_literal: true

module Decidim
  module StudyNotes
    class NotificationMailer < Decidim::ApplicationMailer
      include Decidim::EmailChecker

      def register_to_signum_finished(user)
        @organization = user.organization
        email = user.email
        return if email.blank?
        return unless valid_email?(email)

        mail(to: email, subject: "Zakończono rejestrację uwag w Signum")
      end

      def missing_confirmation(email, study_note)
        return if email.blank?
        return unless valid_email?(email)
        @study_note = study_note
        @organization = study_note.organization

        attachments["#{study_note.pdf_name}.pdf"] = Decidim::PdfGeneratorService.new.save_to_pdf(study_note)
        mail(to: email, subject: "Potwierdzenie złożenia uwagi do planu ogólnego")
      end
    end
  end
end