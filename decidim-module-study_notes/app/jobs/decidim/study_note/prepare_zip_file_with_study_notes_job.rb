# frozen_string_literal: true

module Decidim
  module StudyNote
    class PrepareZipFileWithStudyNotesJob < ApplicationJob
      include Decidim::EmailChecker
      include Decidim::StudyNotes::PdfAnonymisation

      require "fileutils"

      queue_as :events

      PATH_FOR_EXPORT_TEMPLATE = "/decidim/study_notes/shared/show"

      def perform(study_notes_ids, normalized, anonymized, with_attachments, user, component)
        @normalized = normalized
        @anonymized = anonymized
        @with_attachments = with_attachments
        @user = user
        @component = component

        timestamp = Time.current.to_i
        @path_for_export_temp = Rails.root.join("tmp", "export_study_notes-#{timestamp}").to_s
        @path_for_export_tempfile = File.join(@path_for_export_temp, "Eksport_uwag.zip")

        begin
          process_export(study_notes_ids)
        ensure
          clean_temp_files
        end
      end

      private

      def process_export(study_notes_ids)
        study_notes = study_notes_query(study_notes_ids, @component)
        return if study_notes.empty?

        prepare_zip_file(study_notes)
        return unless File.exist?(@path_for_export_tempfile)

        study_note_zip = Decidim::StudyNotes::StudyNoteZip.create!(
          user: @user,
          component: @component,
          normalized: @normalized,
          anonymized: @anonymized,
          with_attachments: @with_attachments
        )

        File.open(@path_for_export_tempfile) do |file|
          study_note_zip.file.attach(io: file, filename: "eksport_uwag.zip", content_type: "application/zip")
        end

        send_notification(study_note_zip)
      end

      def clean_temp_files
        FileUtils.rm_rf(@path_for_export_temp) if @path_for_export_temp && Dir.exist?(@path_for_export_temp)
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
        zf = Decidim::StudyNotes::ZipFileGenerator.new(@path_for_export_temp, @path_for_export_tempfile)
        zf.write
      end

      def prepare_zip_file(study_notes)
        FileUtils.mkdir_p(@path_for_export_temp)

        study_notes.each do |study_note|
          generate_pdf(study_note)
          add_attachments(study_note) if @with_attachments
        end

        create_zip
      end

      #
      # Private: generate file
      #
      def generate_pdf(study_note)
        folder_to_generate = File.join(@path_for_export_temp, folder_name(study_note))
        FileUtils.mkdir_p(folder_to_generate)
        file_path = File.join(folder_to_generate, "#{study_note.pdf_name}.pdf")

        generate_images_from_pdf(study_note) if @normalized
        study_note.reload
        anonymize_study_note(study_note) if @anonymized

        pdf_content = generate_pdf_string(study_note)
        File.write(file_path, pdf_content, mode: "wb")
      end

      #
      # Private: add additional attachments from:
      # files
      # parcel_site_boundary
      # attorney_power_represent_applicant
      # attorney_power_payment_stamp_duty
      #
      def add_attachments(study_note)
        folder_to_generate = File.join(@path_for_export_temp, folder_name(study_note))
        file_prefix = study_note.pdf_name

        study_note.files.each do |file|
          copy_attachment_to_folder(file, folder_to_generate, "#{file_prefix}_9")
        end

        study_note.parcel_site_boundary.order(:id).each_with_index do |file, index|
          copy_attachment_to_folder(file, folder_to_generate, "#{file_prefix}_7a-#{index}")
        end

        if study_note.attorney_power_represent_applicant_or_for_service.attached?
          copy_attachment_to_folder(study_note.attorney_power_represent_applicant_or_for_service, folder_to_generate, "#{file_prefix}_6_1")
        end

        if study_note.attorney_power_payment_stamp_duty_confirm.attached?
          copy_attachment_to_folder(study_note.attorney_power_payment_stamp_duty_confirm, folder_to_generate, "#{file_prefix}_6_2")
        end
      end

      def copy_attachment_to_folder(attachment, folder, file_prefix)
        safe_filename = ActiveSupport::Inflector.transliterate(attachment.filename.to_s)
        dest_path = File.join(folder, "#{file_prefix}_#{safe_filename}")

        # Tempfile.create([safe_filename, ""], binmode: true) do |temp|
        #   temp.write(attachment.download)
        #   temp.rewind
        #
        #   FileUtils.cp(temp.path, dest_path)
        # end

        attachment.download do |chunk|
          File.open(dest_path, "ab") { |f| f.write(chunk) }
        end
      rescue StandardError => e
        Sentry.capture_message("[ExportJob] Failed to copy attachment #{attachment.id}: #{e.message}")
        Rails.logger.error "[ExportJob] Failed to copy attachment #{attachment.id}: #{e.message}"
      end

      #
      # Private: generate pdf from string, with specified params
      #
      def generate_pdf_string(study_note)
        pdf_html = view_context_with_helpers.render_to_string(
          template: PATH_FOR_EXPORT_TEMPLATE,
          locals: { study_note:, normalized: @normalized },
          formats: [:pdf]
        )
        # FIXME: Adam - czy tu nie brakuje zmiennej: normalized: @normalized?
        WickedPdf.new.pdf_from_string(pdf_html, { footer: @normalized ? study_note.pdf_footer : nil })
      end

      #
      # Private: prepare list of study notes from id if its exist, or get all for component
      #
      def study_notes_query(ids, component)
        query = Decidim::StudyNotes::StudyNote.where(component:)
                                              .includes(
                                                :files_blobs,
                                                :parcel_site_boundary_blobs,
                                                :attorney_power_represent_applicant_or_for_service_blob,
                                                :attorney_power_payment_stamp_duty_confirm_blob
                                              )
        ids.present? ? query.where(id: ids) : query
      end

      def generate_images_from_pdf(study_note)
        check_attorney_power_represent_applicant_or_for_service(study_note)
        check_attorney_power_payment_stamp_duty_confirm(study_note)
        check_parcel_site_boundary(study_note)
        check_other_files(study_note)
      end

      def check_attorney_power_represent_applicant_or_for_service(study_note)
        return unless study_note.attorney_power_represent_applicant_or_for_service.attached? && study_note.attorney_power_represent_applicant_or_for_service.blob.content_type == "application/pdf"

        study_note.attorney_power_represent_applicant_or_for_service_img.destroy_all if study_note.attorney_power_represent_applicant_or_for_service_img.any?
        generate_images_for(study_note, study_note.attorney_power_represent_applicant_or_for_service, "attorney_power_represent_applicant_or_for_service_img")
      end

      def check_attorney_power_payment_stamp_duty_confirm(study_note)
        return unless study_note.attorney_power_payment_stamp_duty_confirm.attached? && study_note.attorney_power_payment_stamp_duty_confirm.blob.content_type == "application/pdf"

        study_note.attorney_power_payment_stamp_duty_confirm_img.destroy_all if study_note.attorney_power_payment_stamp_duty_confirm_img.any?
        generate_images_for(study_note, study_note.attorney_power_payment_stamp_duty_confirm, "attorney_power_payment_stamp_duty_confirm_img")
      end

      def check_parcel_site_boundary(study_note)
        return unless study_note.parcel_site_boundary.any?
        return if study_note.parcel_site_boundary_img.any?

        study_note.parcel_site_boundary.each do |file|
          generate_images_for(study_note, file, "parcel_site_boundary_img") if file.blob.content_type == "application/pdf"
        end
      end

      def folder_name(study_note)
        [study_note.sequential_number,
         study_note.id.to_s,
         study_note.created_at.strftime("%F").to_s].compact_blank.join("_")
      end

      def check_other_files(study_note)
        return unless study_note.files.any?
        return if study_note.files_img.any?

        study_note.files.each do |file|
          generate_images_for(study_note, file, "files_img") if file.blob.content_type == "application/pdf"
        end
      end

      def generate_images_for(study_note, source_file, output_attr_name)
        tempfile = Tempfile.new([source_file.filename.to_s, ".pdf"], binmode: true)
        begin
          source_file.download { |chunk| tempfile.write(chunk) }
          tempfile.rewind

          mini_magic_pdf = MiniMagick::Image.open(tempfile.path)
          mini_magic_pdf.pages.each_with_index do |page, index|
            file_name = "#{source_file.filename.base}-#{(index + 1)}.#{source_file.filename.extension}"
            converted_file_path = File.join(Dir.tmpdir, "#{file_name}-#{Time.zone.now.strftime("%Y%m%d")}-#{rand(0x100000000).to_s(36)}-.png")

            MiniMagick::Tool::Convert.new do |convert|
              convert.background "white"
              convert.flatten
              convert.density 300
              convert.quality 100
              convert << page.path
              convert << converted_file_path
            end

            if File.exist?(converted_file_path)
              study_note.send(output_attr_name).attach(
                io: File.open(converted_file_path),
                filename: file_name,
                content_type: "image/png"
              )
              FileUtils.rm(converted_file_path)
            end
          end
        rescue StandardError => e
          Sentry.capture_exception(e)
        ensure
          tempfile.close!
        end
      end

      # Private: Use action base controller and add required helpers to generate pdf file
      #
      def view_context_with_helpers
        controller = ActionController::Base.new
        controller.view_context_class.include(Decidim::StudyNotes::StudyNotesHelper)
        controller
      end
    end
  end
end
