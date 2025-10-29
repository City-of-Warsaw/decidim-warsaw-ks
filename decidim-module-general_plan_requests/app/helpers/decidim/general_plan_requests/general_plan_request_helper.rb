# frozen_string_literal: true

module Decidim
  module GeneralPlanRequests
    module GeneralPlanRequestHelper
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

      def hyperlink_for_descriptions
        'https://architektura.um.warszawa.pl/documents/12025039/112612512/2024_08_12_STREFY+PLANISTYCZNE.pdf/ec21fbbf-eede-1775-8129-2a0e73a0ff9e?t=1724336393626'
      end

      def request_body_description_with_hyperlinks
        description = <<-HTML
          <ul>  
            <li><strong>Maksymalnie 1000 znaków.</strong> Jeśli chcesz wpisać więcej treści — załącz ją w osobnym pliku (załącznik dodasz w ostatniej części formularza).</li>
            <li>
              <strong>W treści wpisz co najmniej:</strong>
              <ul>
                <li>jakiej lokalizacji dotyczy Twój wniosek (np. numer działki i obrębu, adres) — informację tę możesz ewentualnie wpisać w punkcie 7.2 lub 7.3 </li>
                <li>czego dotyczy Twój wniosek (np. o jaką strefę planistyczną wnioskujesz) — informację tę możesz ewentualnie wpisać w punkcie 7.2 lub 7.3 </li>
              </ul>
            </li>

            <li>
              Jeśli chcesz sprawdzić, jakie są możliwe rodzaje stref planistycznych, kliknij #{link_to('tutaj', hyperlink_for_descriptions, target: '_blank')}.
            </li>

            <li>
              Jeśli chcesz sprawdzić, jaki jest identyfikator Twojej działki, sprawdź na #{link_to('Geoportalu', 'https://mapy.geoportal.gov.pl/', target: '_blank')}.
            </li>
          </ul>
        HTML

        description.html_safe
      end

      def area_class_name_description
        description = <<-HTML
          Jeśli chcesz sprawdzić, jakie są możliwe klasy przeznaczenia terenu w poszczególnych strefach planistycznych, kliknij 
          #{link_to('tutaj', hyperlink_for_descriptions, target: '_blank')}.
        HTML

        description.html_safe
      end

      # Public: Displays general plan request files with labels.
      #
      # param gpr [Object] The general plan request object containing the files.
      # return: [String] The HTML output displaying the file information and labels.
      def display_other_files(gpr)
        i18n_file = I18n.t('decidim.general_plan_requests.admin.general_plan_requests.show.file')
        i18n_file_filename = I18n.t('decidim.general_plan_requests.admin.general_plan_requests.show.file_filename')
        i18n_download_file = I18n.t('decidim.general_plan_requests.admin.general_plan_requests.show.download_file')
        files = gpr.files

        output = ''

        # Always display the first file label
        output += view_context.content_tag(:p) do
          view_context.content_tag(:strong, i18n_file + ': ') +
            (files.any? ? files.first.filename.to_s : '') +
            (if files.any?
               '  '.html_safe + view_context.icon_link_to('data-transfer-download',
                                                          main_app.rails_blob_path(files.first, disposition: 'attachment'),
                                                          i18n_download_file,
                                                          class: 'action-icon--data-transfer-download')
             else
               ''
             end)
        end

        output += view_context.content_tag(:p) do
          view_context.content_tag(:strong, i18n_file_filename + ': ') +
            (files.any? ? gpr.files_filename_one.to_s : '')
        end

        # Always display the second file label.
        # The form accepts between 0 to 2 files
        output += view_context.content_tag(:p) do
          view_context.content_tag(:strong, i18n_file + ': ') +
            (files.count == 2 ? files.last.filename.to_s : '') +
            (if files.count == 2
               '  '.html_safe + view_context.icon_link_to('data-transfer-download',
                                                          main_app.rails_blob_path(files.last, disposition: 'attachment'),
                                                          i18n_download_file,
                                                          class: 'action-icon--data-transfer-download')
             else
               ''
             end)
        end

        output += view_context.content_tag(:p) do
          view_context.content_tag(:strong, i18n_file_filename + ': ') +
            (files.count == 2 ? gpr.files_filename_two.to_s : '')
        end

        output.html_safe
      end
    end
  end
end
