# frozen_string_literal: true

module Decidim
  module StudyNotes
    module Admin
      #  wysyłka e-maili do osób, które nie otrzymały potwierdzenia złożenia uwagi z komponentu do planu ogólnego.
      class SendMissingSignumConfirmations < Decidim::Command

        def initialize
          @from_date = Date.parse("2025-11-14").beginning_of_day
          @to_date = Date.parse("2026-01-22").end_of_day
        end

        def call
          missing_confirmation_study_notes.each do |study_note|
            send_notification(study_note)
            study_note.mark_submitter_confirmation_send
          end
        end

        private

        def missing_confirmation_study_notes
          @study_notes ||= Decidim::StudyNotes::StudyNote.where(created_at: @from_date..@to_date)
                                        .where.not(signum_registered_by_user_id: nil)
                                        .where(optional_confirmation_request: true) # prosba o potwierdzenie
                                        .where.not(email_confirmation_request: nil)
                                        .where.not(email_confirmation_request: "") # podany email
                                        .where(declaration_remote_correspondence: true) # zgoda na komunikacje elektroniczna
                                        .where(submitter_confirmation_send: false)
        end

        def send_notification(study_note)
          return if study_note.email_confirmation_request.blank?

          Rails.logger.info "Sending email to study_note id: #{study_note.id}"
          Decidim::StudyNotes::NotificationMailer.missing_confirmation(study_note.email_confirmation_request, study_note).deliver_now
        end

        def clean_user_id_from_registered_study_notes
          Decidim::StudyNotes::StudyNote.where.not(signum_registered_by_user_id: nil).each do |study_note|
            # testujemy usera czy jest z AD
            user = Decidim::User.find(study_note.signum_registered_by_user_id)
            next if user.ad_name

            # tu czysicimy user_id jesli user nie byl z AD
            study_note.update_column(:signum_registered_by_user_id, nil)
          end
          true
        end
      end
    end
  end
end