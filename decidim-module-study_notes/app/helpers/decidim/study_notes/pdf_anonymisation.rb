# frozen_string_literal: true

module Decidim
  module StudyNotes
    module PdfAnonymisation
      private

      def anonymize_study_note(study_note)
        # do not anonymize organisation data
        if study_note.submitter_data_role == Decidim::StudyNotes::StudyNote::INDIVIDUAL
          anonymize_submitter_data(study_note)
        end

        # all mailing address data can be blank or all mailing data must be filled in the form
        if study_note.mailing_address_data_country.present?
          anonymize_mailing_address_data(study_note)
        end

        # all attorney data can be blank or all attorney data must be filled in the form
        if study_note.attorney_data_first_name.present?
          anonymize_attorney_data(study_note)
        end
      end

      def anonymize_submitter_data(study_note)
        study_note.submitter_data_first_name = '*********'
        study_note.submitter_data_last_name = '*********'
        study_note.submitter_data_country = '*********'
        study_note.submitter_data_voivodeship = '*********'
        study_note.submitter_data_county = '*********'
        study_note.submitter_data_community = '*********'
        study_note.submitter_data_street = '*********'
        study_note.submitter_data_street_number = '***'
        study_note.submitter_data_flat_number = '***'
        study_note.submitter_data_city = '*********'
        study_note.submitter_data_zip_code = '******'
        study_note.submitter_data_phone_number = '*********'
        study_note.submitter_data_email = '*********'
        study_note.submitter_data_epuap_delivery_address = '*********'
      end

      def anonymize_mailing_address_data(study_note)
        study_note.mailing_address_data_country = '*********'
        study_note.mailing_address_data_voivodeship = '*********'
        study_note.mailing_address_data_county = '*********'
        study_note.mailing_address_data_community = '*********'
        study_note.mailing_address_data_street = '*********'
        study_note.mailing_address_data_street_number = '***'
        study_note.mailing_address_data_flat_number = '***'
        study_note.mailing_address_data_city = '*********'
        study_note.mailing_address_data_zip_code = '******'
      end

      def anonymize_attorney_data(study_note)
        study_note.attorney_data_first_name = '*********'
        study_note.attorney_data_last_name = '*********'
        study_note.attorney_data_country = '*********'
        study_note.attorney_data_voivodeship = '*********'
        study_note.attorney_data_county = '*********'
        study_note.attorney_data_community = '*********'
        study_note.attorney_data_street = '*********'
        study_note.attorney_data_street_number = '***'
        study_note.attorney_data_flat_number = '***'
        study_note.attorney_data_city = '*********'
        study_note.attorney_data_zip_code = '******'
        study_note.attorney_data_phone_number = '*********'
        study_note.attorney_data_email = '*********'
        study_note.attorney_data_epuap_delivery_address = '*********'
      end
    end
  end
end
