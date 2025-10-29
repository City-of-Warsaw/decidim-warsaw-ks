# frozen_string_literal: true
module Decidim
  module StudyNotes
    module Admin
      # This class holds a Form to create zip_file.
      class StudyNoteZipForm < Decidim::Form
        attribute :study_notes_ids, Array, default: []
        attribute :normalized, Boolean, default: false
        attribute :anonymized, Boolean, default: false
        attribute :with_attachments, Boolean, default: false
      end
    end
  end
end
