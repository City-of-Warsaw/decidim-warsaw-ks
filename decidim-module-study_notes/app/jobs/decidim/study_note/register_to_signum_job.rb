# frozen_string_literal: true

module Decidim
  module StudyNote
    # Register study note to signum
    class RegisterToSignumJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      def perform(study_note, user)
        Decidim::SignumService.new.register_study_note_to_signum(study_note:, user:)
      end
    end
  end
end
