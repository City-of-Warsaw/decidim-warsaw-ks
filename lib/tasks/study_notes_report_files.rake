require "csv"

namespace :study_notes_report_files do
  desc "Generate files for selected study notes"
  task report: :environment do
    timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
    output_path = Rails.root.join("tmp", "study_notes_report_files_#{timestamp}.csv")
    component_id = 116 #454

    CSV.open(output_path, "w") do |csv|
      @csv = csv
      @csv << [
        "Id uwagi",
        "typ zalacznika",
        "czy jest załącznik?",
        "wielkośc załącznika",
        "wielkośc załącznika po analizie",
        "data dodania"
      ]

      Decidim::StudyNotes::StudyNote.where(:decidim_component_id => component_id).find_each do |study_note|
        check_file(study_note, study_note.attorney_power_represent_applicant_or_for_service,"Pełnomocnictwo reprezentowania lub doręczeń")
        check_file(study_note, study_note.attorney_power_payment_stamp_duty_confirm,"Potwierdzenie uiszczenia opłaty skarbowej od pełnomocnictwa ")
        study_note.parcel_site_boundary.each do |attachment|
          check_file(study_note, attachment,"Określenie granic terenu")
        end
        study_note.files.each do |attachment|
          check_file(study_note, attachment,"Dodatkowy załącznik")
        end
      end
    end




    puts "Report generated:"
    puts output_path
  end

  def check_file(study_note, source_attachment, type)
    service = ActiveStorage::Blob.service

    file = source_attachment.blob
    return if file.nil?

    disk_size = nil
    exists = file.service.exist?(file.key)

    if exists
      path = service.send(:path_for, file.key)
      disk_size = File.exist?(path) ? File.size(path) : "0"
    end
    if disk_size == "0"
    @csv << [
      study_note.id,
      type,
      exists,
      file.byte_size,
      disk_size,
      file.created_at
    ]
    end
  end
end
