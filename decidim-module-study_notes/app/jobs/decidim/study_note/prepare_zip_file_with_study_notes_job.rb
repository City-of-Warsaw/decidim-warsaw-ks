# frozen_string_literal: true

module Decidim
  module StudyNote
    class PrepareZipFileWithStudyNotesJob < ApplicationJob
      include Decidim::EmailChecker
      include Decidim::StudyNotes::PdfAnonymisation

      require "fileutils"

      queue_as :events

      PATH_FOR_EXPORT_TEMP = Rails.root.join("tmp/export_study_notes").to_s.freeze
      PATH_FOR_EXPORT_TEMPLATE = "/decidim/study_notes/shared/show"
      PATH_FOR_EXPORT_TEMPFILE = "#{PATH_FOR_EXPORT_TEMP}/Eksport_uwag.zip".freeze

      def perform(study_notes_ids, normalized, anonymized, with_attachments, user, component)
        @normalized = normalized
        @anonymized = anonymized
        @with_attachments = with_attachments

        prepare_zip_file(study_notes(study_notes_ids, component))
        study_note_zip = Decidim::StudyNotes::StudyNoteZip.create!(user:, component:, normalized:, anonymized:, with_attachments:)

        File.open(PATH_FOR_EXPORT_TEMPFILE) do |file|
          study_note_zip.file.attach(io: file, filename: "eksport_uwag.zip", content_type: "application/zip")
        end

        clean_temp_files
        send_notification(study_note_zip)
      end

      private

      def clean_temp_files
        FileUtils.rm_rf(PATH_FOR_EXPORT_TEMP)
      end

      def send_notification(study_note_zip)
        return unless valid_email?(study_note_zip.user.email)

        study_note_zip_link = Decidim::EngineRouter.admin_proxy(study_note_zip.component)
                                                   .get_file_study_notes_url(uuid: study_note_zip.uuid)

        Decidim::CoreExtended::TemplatedMailer.notify(
          "study_note_zip_notification", study_note_zip.user, { study_note_zip_link: }
        ).deliver_later
      end

      # @private - create_zip
      #
      def create_zip
        zf = Decidim::StudyNotes::ZipFileGenerator.new(PATH_FOR_EXPORT_TEMP, PATH_FOR_EXPORT_TEMPFILE)
        zf.write
      end

      def prepare_file_list_to_zip(study_notes)
        study_notes.each do |study_note|
          generate_pdf(study_note)
          add_attachments(study_note) if @with_attachments
        end
      end

      def prepare_zip_file(study_notes)
        FileUtils.mkdir_p(PATH_FOR_EXPORT_TEMP)

        file_list = prepare_file_list_to_zip(study_notes)
        create_zip if file_list.any?
      end

      #
      # Private: generate file
      #
      def generate_pdf(study_note)
        folder_to_generate = PATH_FOR_EXPORT_TEMP + "/#{study_note.id}"
        FileUtils.mkdir_p(folder_to_generate)
        file_name = [study_note.sequential_number,
                     study_note.id.to_s,
                     Time.current.strftime("%F").to_s,
                     "potwierdzenie"].compact_blank.join("_")
        file_path = folder_to_generate + "/#{file_name}.pdf"
        File.write(file_path, generate_pdf_string(study_note), mode: "wb")
      end

      #
      # Private: add additional attachments from:
      # files
      # parcel_site_boundary
      # attorney_power_represent_applicant
      # attorney_power_payment_stamp_duty
      #
      def add_attachments(study_note)
        folder_to_generate = PATH_FOR_EXPORT_TEMP.to_s + "/#{study_note.id}"
        prefix_file_name = [study_note.sequential_number,
                     study_note.id.to_s,
                     Time.current.strftime("%F").to_s].compact_blank.join("_")

        if study_note.files.any?
          study_note.files.each do |file|
            file_storage = ActiveStorage::Blob.service.path_for(file.key)
            FileUtils.cp(file_storage, "#{folder_to_generate}/#{prefix_file_name + "_" + file.filename.to_s}")
          end
        end

        if study_note.parcel_site_boundary.any?
          study_note.parcel_site_boundary.each do |file|
            file_storage = ActiveStorage::Blob.service.path_for(file.key)
            FileUtils.cp(file_storage, "#{folder_to_generate}/#{prefix_file_name + "_" + file.filename.to_s}")
          end
        end

        if study_note.attorney_power_represent_applicant_or_for_service.attached?
          file_storage = ActiveStorage::Blob.service.path_for(file.key)
          FileUtils.cp(file_storage, "#{folder_to_generate}/#{prefix_file_name + "_" + file.filename.to_s}")
        end

        if study_note.attorney_power_payment_stamp_duty_confirm.attached?
          file_storage = ActiveStorage::Blob.service.path_for(file.key)
          FileUtils.cp(file_storage, "#{folder_to_generate}/#{prefix_file_name + "_" + file.filename.to_s}")
        end
      end

      #
      # Private: generate pdf from string, with specified params
      #
      def generate_pdf_string(study_note)
        anonymize_study_note(study_note) if @anonymized
        pdf_html = view_context_with_helpers.render_to_string(
          template: PATH_FOR_EXPORT_TEMPLATE,
          locals: { study_note:, normalized: @normalized },
          formats: [:pdf]
        )
        WickedPdf.new.pdf_from_string(pdf_html)
      end

      # Private: Use action base controller and add required helpers to generate pdf file
      #
      def view_context_with_helpers
        controller = ActionController::Base.new
        controller.view_context_class.include(Decidim::StudyNotes::StudyNotesHelper)
        controller
      end

      #
      # Private: prepare list of study notes from id if its exist, or get all for component
      #
      def study_notes(ids, component)
        collection = Decidim::StudyNotes::StudyNote.where(component:)
        ids.present? ? collection.where(id: ids) : collection
      end
    end
  end
end
