module Decidim::StudyNotes
  module StudyNotesHelper
    def submitter_full_name
      "#{submitter_data_first_name} #{submitter_data_last_name}"
    end

    def submitter_name
      submitter_data_org_name.presence || submitter_full_name
    end

    def submitter_full_adress
      "#{submitter_data_country}
      #{submitter_data_voivodeship}
      #{submitter_data_county}
      #{submitter_data_community}
      #{submitter_data_street}
      #{submitter_data_street_number} #{submitter_data_flat_number.present? ? '/' : nil}#{submitter_data_flat_number},
      #{submitter_data_city}
      #{submitter_data_zip_code}"
    end

    def mailing_address
      "#{mailing_address_data_country}
      #{mailing_address_data_street}
      #{mailing_address_data_street_number}
      #{mailing_address_data_flat_number.present? ? '/' : nil}
      #{mailing_address_data_flat_number}, #{mailing_address_data_zip_code}
      #{mailing_address_data_city}
      #{mailing_address_data_county}"
    end

    def attorney_address
      "#{attorney_data_country}
      #{attorney_data_street}
      #{attorney_data_street_number}
      #{attorney_data_flat_number.present? ? '/' : nil}#{attorney_data_flat_number}, #{attorney_data_zip_code}
      #{attorney_data_city}"
    end

    def file_present?(file)
      file.is_a?(ActionDispatch::Http::UploadedFile) || (file.respond_to?(:attached?) && file.attached?)
    end

    def col_index_to_column_letter(index)
      return '' if index.negative?

      letter = ''
      while index >= 0
        letter = (65 + (index % 26)).chr + letter
        index = (index / 26) - 1
      end

      letter
    end

    def request_body_description_with_hyperlinks
      description = <<-HTML
        Wpisz tutaj swoje uwagi ogólne, które nie dotyczą konkretnych lokalizacji, lub uwagi, które nie mieszczą się w zakresie uwag z sekcji 7a.<br /><br />
        Maksimum 1000 znaków. Jeśli chcesz wpisać więcej treści – załącz ją w osobnym pliku (załącznik dodasz w ostatniej części formularza).
      HTML

      description.html_safe
    end

    # Public: Displays general plan request files with labels.
    #
    # param study_note [Object] The general plan request object containing the files.
    # return: [String] The HTML output displaying the file information and labels.
    def display_other_files(study_note)
      return "Brak załączników" if study_note.files.empty?

      i18n_file = I18n.t('decidim.general_plan_requests.admin.general_plan_requests.show.file')
      i18n_file_filename = I18n.t('decidim.general_plan_requests.admin.general_plan_requests.show.file_filename')
      i18n_download_file = I18n.t('decidim.general_plan_requests.admin.general_plan_requests.show.download_file')
      output = ""
      study_note.files.each_with_index do |file, index|
        output += content_tag(:p) do
          [
            content_tag(:strong, "#{i18n_file}:"),
            file.filename.to_s,
            icon_link_to('download-line',
                         main_app.rails_blob_path(file, disposition: 'attachment'),
                         i18n_download_file,
                         class: 'action-icon--data-transfer-download ml-2 [&_svg]:inline')
          ].join(" ").html_safe
        end

        output += content_tag(:p) do
          filename = index.zero? ? study_note.files_filename_one : study_note.files_filename_two
          filename = file.filename if index > 1
          [content_tag(:strong, "#{i18n_file_filename}:"), filename.to_s].join(" ").html_safe
        end
      end

      output.html_safe
    end

    # Public: Displays an attorney-related file with label and download icon.
    #
    # param study_note [Object] The study note object containing the file.
    # param field [Symbol] The attachment field name (e.g., :attorney_power_represent_applicant_or_for_service).
    # param i18n_scope [String] The translation scope for label and tooltip.
    # return [String] The HTML output displaying the file info and label.
    def display_attorney_file(study_note, field, i18n_scope)
      label = t("#{i18n_scope}.name")
      i18n_download_file = t("decidim.study_notes.admin.study_notes.show.#{field}.download_file")
      file = study_note.public_send(field)
      unless file&.attached?
        return content_tag(:p) do
          concat(content_tag(:strong, "#{label}: "))
          concat("Brak")
        end
      end
      download_url = main_app.rails_blob_path(file, disposition: "attachment")
      content_tag(:p) do
        concat(content_tag(:strong, "#{label}: "))
        concat(
          content_tag(:span, class: "attorney-file-service-inline") do
            concat(content_tag(:span, file.filename.to_s))
            concat(
              icon_link_to(
                "download-line",
                download_url,
                i18n_download_file,
                class: "action-icon--data-transfer-download ml-2 [&_svg]:inline"
              )
            )
          end
        )
      end
    end

    # Public: Displays parcel boundary files with labels.
    #
    # param study_note [Object] The study note object containing the files.
    # return: [String] The HTML output displaying the file information and labels.
    def display_parcel_site_boundary_files(study_note)
      i18n_file = I18n.t('decidim.study_notes.admin.study_notes.show.parcel_site_boundary')
      i18n_file_filename = I18n.t('decidim.study_notes.admin.study_notes.show.file_filename')
      i18n_download_file = I18n.t('decidim.study_notes.admin.study_notes.show.download_file')
      files = study_note.parcel_site_boundary

      output = ''

      return "Brak załączników" if files.empty?

      filtered_detailed_notes = JSON.parse(study_note.detailed_notes).select do |detailed_note|
        detailed_note["is_parcel_site_boundary_included"] == "true"
      end

      return "Brak załączników" if filtered_detailed_notes.empty?

      files.each_with_index do |file, index|
        output += content_tag(:p) do
          content_tag(:strong, "#{i18n_file} - teren #{filtered_detailed_notes[index]["index"].to_i + 1}: ") +
            (files.any? ? file.filename.to_s : '') +
            (if files.any?
                '  '.html_safe + icon_link_to('download-line',
                                                          main_app.rails_blob_path(file, disposition: 'attachment'),
                                                          i18n_download_file,
                                                          class: 'action-icon--data-transfer-download ml-2 [&_svg]:inline')
              else
                ''
              end)
        end
      end 

      output.html_safe
    end

    def file_url(file)
      # file.blob.url
      Rails.application.routes.url_helpers.rails_blob_url(file, host: Decidim::Organization.first.host)
    end

  end 
end
