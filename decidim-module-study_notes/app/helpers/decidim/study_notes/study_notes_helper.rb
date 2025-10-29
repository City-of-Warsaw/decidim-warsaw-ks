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
      i18n_file = I18n.t('decidim.general_plan_requests.admin.general_plan_requests.show.file')
      i18n_file_filename = I18n.t('decidim.general_plan_requests.admin.general_plan_requests.show.file_filename')
      i18n_download_file = I18n.t('decidim.general_plan_requests.admin.general_plan_requests.show.download_file')
      files = study_note.files

      output = ''

      return "Brak załączników" if files.empty?

      # Always display the first file label
      output += content_tag(:p) do
        content_tag(:strong, i18n_file + ': ') +
          (files.any? ? files.first.filename.to_s : '') +
          (if files.any?
              '  '.html_safe + icon_link_to('download-line',
                                                        main_app.rails_blob_path(files.first, disposition: 'attachment'),
                                                        i18n_download_file,
                                                        class: 'action-icon--data-transfer-download')
            else
              ''
            end)
      end

      output += content_tag(:p) do
        content_tag(:strong, i18n_file_filename + ': ') +
          (files.any? ? study_note.files_filename_one.to_s : '')
      end

      # Always display the second file label.
      # The form accepts between 0 to 2 files
      output += content_tag(:p) do
        content_tag(:strong, i18n_file + ': ') +
          (files.count == 2 ? files.last.filename.to_s : '') +
          (if files.count == 2
              '  '.html_safe + icon_link_to('data-transfer-download',
                                                        main_app.rails_blob_path(files.last, disposition: 'attachment'),
                                                        i18n_download_file,
                                                        class: 'action-icon--data-transfer-download')
            else
              ''
            end)
      end

      output += content_tag(:p) do
        content_tag(:strong, i18n_file_filename + ': ') +
          (files.count == 2 ? study_note.files_filename_two.to_s : '')
      end

      output.html_safe
    end
  end 
end
