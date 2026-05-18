# frozen_string_literal: true

module Decidim
  module StudyNote
    class RegisterSelectedToSignumJob < ApplicationJob
      queue_as :events
      include Decidim::EmailChecker

      def perform(user, ids)
        @user = user
        @ids = ids

        study_notes.each do |study_note|
          register_to_signum(study_note)
        end

        send_notification(user)
      end

      private

      def study_notes
        @study_notes ||= Decidim::StudyNotes::StudyNote.where(id: @ids).where(signum_nr_kancelaryjny: nil)
      end

      def register_to_signum(study_note)
        Decidim::SignumService.new.register_study_note_to_signum(study_note: study_note, user: @user)
      end

      # send admin notification after sending oll study notes to Signum
      def send_notification(user)
        return unless valid_email?(user.email)

        Decidim::StudyNotes::NotificationMailer.register_to_signum_finished(user).deliver_now
      end
    end
  end
end
