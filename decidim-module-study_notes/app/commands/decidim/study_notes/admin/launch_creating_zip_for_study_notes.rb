# frozen_string_literal: true

module Decidim
  module StudyNotes
    module Admin
      # This command is executed when user wants to generate study notes zip file
      class LaunchCreatingZipForStudyNotes < Decidim::Command
        def initialize(form, current_component)
          @form = form
          @current_user = form.current_user
          @current_component = current_component
        end

        # Launch preparing zip with pdfs confirmations of study notes
        #
        # Broadcasts :ok
        def call
          prepare_zip_file

          broadcast(:ok)
        end

        private

        attr_reader :form, :current_user, :current_component

        def prepare_zip_file
          Decidim::StudyNote::PrepareZipFileWithStudyNotesJob.perform_later(form.study_notes_ids,
                                                                            form.normalized,
                                                                            form.anonymized,
                                                                            form.with_attachments,
                                                                            current_user,
                                                                            current_component)
        end
      end
    end
  end
end