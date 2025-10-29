# frozen_string_literal: true

require_dependency 'file_form_validator'

module Decidim
  module StudyNotes
    class StudyNoteZip < ApplicationRecord
      include Decidim::HasComponent

      before_create :generate_uuid
      has_one_attached :file

      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

      def generate_uuid
        self.uuid = SecureRandom.hex(36)
        self.uuid = SecureRandom.hex(36) while StudyNoteZip.find_by(uuid:)
      end
    end
  end
end
