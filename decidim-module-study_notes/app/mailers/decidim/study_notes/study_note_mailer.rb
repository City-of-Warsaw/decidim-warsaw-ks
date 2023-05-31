# frozen_string_literal: true

module Decidim::StudyNotes
  class StudyNoteMailer < Decidim::ApplicationMailer
    # official_img_header

    def notify_user(study_note)
      @organization = study_note.component.organization
      @study_note = study_note
      attachments["#{study_note.id}_potwierdzenie.pdf"] = Decidim::PdfGeneratorService.new.save_study_note_to_pdf(@study_note)
      mail(to: @study_note.email, subject: 'Dziękujemy za Twoje zgłoszenie uwagi do studium')
    end
  end
end
