# frozen_string_literal: true

module Decidim
  module StudyNote
    class GenerateSequentialNumbersForStudyNotesJob < ApplicationJob
      queue_as :events
      include Decidim::EmailChecker

      def perform(start_number, component, user)
        generate_sequence_numbers(start_number, component)
        send_notification(user)
      end

      private

      def generate_sequence_numbers(start_number, component)
        Decidim::StudyNotes::StudyNote.where(component:).order(:created_at).each do |study_note|
          study_note.update(sequential_number: start_number)
          start_number += 1
        end
      end

      def send_notification(user)
        return unless valid_email?(user.email)

        Decidim::CoreExtended::TemplatedMailer.notify(
          "generate_sequential_numbers_for_study_notes", user, {}
        ).deliver_later
      end
    end
  end
end
