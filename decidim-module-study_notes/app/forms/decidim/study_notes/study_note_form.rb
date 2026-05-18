# frozen_string_literal: true

require "valid_email2"
require 'obscenity/active_model'
require_dependency 'file_form_validator'

module Decidim
  module StudyNotes
    # This class holds a Form to create single study note for process component.
    class StudyNoteForm < Decidim::Form
      include ActionView::Helpers::UrlHelper
      include Decidim::StudyNotes::StudyNotesHelper
      include ActiveModel::Validations::Callbacks

      mimic :study_note

      # ATTRIBUTES:

      # attrs for sections 1, 2, 3
      attribute :authority_name_which_letter_is_addressed, String, default: 'Prezydent m.st. Warszawy'
      attribute :letter_type, Integer, default: 1
      attribute :urban_planning_act_type, Integer, default: 0

      # attrs for section 4 - submitter data
      attribute :submitter_data_role, Integer # 0 - osoba fizyczna / 1 - jednostka organizacyjna
      attribute :submitter_data_first_name, String
      attribute :submitter_data_last_name, String
      attribute :submitter_data_org_name, String
      attribute :submitter_data_country, String
      attribute :submitter_data_voivodeship, String
      attribute :submitter_data_county, String
      attribute :submitter_data_community, String
      attribute :submitter_data_street, String
      attribute :submitter_data_street_number, String
      attribute :submitter_data_flat_number, String
      attribute :submitter_data_city, String
      attribute :submitter_data_zip_code, String
      attribute :submitter_data_email, String
      attribute :submitter_data_phone_number, String
      attribute :submitter_data_epuap_delivery_address, String
      attribute :perpetual_owner_of_the_property, Boolean

      # attrs for section 5 - mailing address data
      attribute :mailing_address_data_country, String
      attribute :mailing_address_data_voivodeship, String
      attribute :mailing_address_data_county, String
      attribute :mailing_address_data_community, String
      attribute :mailing_address_data_street, String
      attribute :mailing_address_data_street_number, String
      attribute :mailing_address_data_flat_number, String
      attribute :mailing_address_data_city, String
      attribute :mailing_address_data_zip_code, String

      # attrs for section 6 - attorney data
      attribute :attorney_data_role, Integer # 0 - pełnomocnik / 1 - pełnomocnik do doręczeń
      attribute :attorney_data_first_name, String
      attribute :attorney_data_last_name, String
      attribute :attorney_data_country, String
      attribute :attorney_data_voivodeship, String
      attribute :attorney_data_county, String
      attribute :attorney_data_community, String
      attribute :attorney_data_street, String
      attribute :attorney_data_street_number, String
      attribute :attorney_data_flat_number, String
      attribute :attorney_data_city, String
      attribute :attorney_data_zip_code, String
      attribute :attorney_data_email, String
      attribute :attorney_data_phone_number, String
      attribute :attorney_data_epuap_delivery_address, String
      attribute :attorney_power_represent_applicant_or_for_service
      attribute :attorney_power_payment_stamp_duty_confirm

      # attrs for section 7 - letter content
      # attrs for sub-section 7.1
      attribute :detailed_notes, Hash, default: nil

      # attrs for sub-section 7.2
      attribute :request_body, String

      # attrs for section 8 - declaration remote correspondence
      attribute :declaration_remote_correspondence, Boolean

      # attrs for section 9 - attachments
      attribute :files
      attribute :parcel_site_boundary
      attribute :files_filename_one, String # also migrated
      attribute :files_filename_two, String # also migrated

      # attrs for additional section - optional email confirmation request
      attribute :optional_confirmation_request, Boolean
      attribute :email_confirmation_request, String

      # last attrs
      attribute :confirm_read_process_description, Boolean
      attribute :confirm_process_personal_data, Boolean, default: false

      before_validation :sanitize_detailed_notes

      # VALIDATIONS 
      # validations for section 4 - submitter data
      validates :submitter_data_role, presence: true
      validates :submitter_data_first_name,
                presence: true,
                if: ->(form) {
                  form.submitter_data_role.to_s == Decidim::StudyNotes::StudyNote::INDIVIDUAL
                }
      validates :submitter_data_last_name,
                presence: true,
                if: ->(form) {
                  form.submitter_data_role.to_s == Decidim::StudyNotes::StudyNote::INDIVIDUAL
                }
      validates :submitter_data_org_name,
                presence: true,
                if: ->(form) {
                  form.submitter_data_role.to_s == Decidim::StudyNotes::StudyNote::ORGANIZATION
                }
      validate :submitter_full_name_or_org_name
      validates :submitter_data_country,
                :submitter_data_voivodeship,
                :submitter_data_county,
                :submitter_data_community,
                :submitter_data_street,
                :submitter_data_street_number,
                :submitter_data_city,
                :submitter_data_zip_code,
                presence: true
      validates :submitter_data_first_name, length: { maximum: 30 }
      validates :submitter_data_last_name, length: { maximum: 80 }
      validates :submitter_data_org_name, length: { maximum: 150 }
      validates :submitter_data_street, length: { maximum: 65 }
      validates :submitter_data_street_number, length: { maximum: 10 }
      validates :submitter_data_flat_number, length: { maximum: 10 }
      validates :submitter_data_city, length: { maximum: 56 }
      validates :submitter_data_zip_code, length: { maximum: 6 }
      validates :submitter_data_country,
                :submitter_data_voivodeship,
                :submitter_data_county,
                :submitter_data_community,
                :submitter_data_email,
                :submitter_data_epuap_delivery_address,
                length: { maximum: 100 }
      validates :submitter_data_phone_number, length: { maximum: 30 }
      validates :submitter_data_email,
                'valid_email_2/email': { disposable: false },
                if: ->(form) { form.submitter_data_email.present? }
      validates :perpetual_owner_of_the_property, inclusion: { in: [true, false] }

      # validations for section 5 - mailing address data
      validates :mailing_address_data_street, length: { maximum: 65 }
      validates :mailing_address_data_street_number, length: { maximum: 10 }
      validates :mailing_address_data_flat_number, length: { maximum: 10 }
      validates :mailing_address_data_city, length: { maximum: 56 }
      validates :mailing_address_data_zip_code, length: { maximum: 6 }
      validates :mailing_address_data_country,
                :mailing_address_data_voivodeship,
                :mailing_address_data_county,
                :mailing_address_data_community,
                length: { maximum: 100 }
      validate :mailing_address_data_incomplete?

      # validations for section 6 - attorney data
      validates :attorney_data_first_name, length: { maximum: 30 }
      validates :attorney_data_last_name, length: { maximum: 80 }
      validates :attorney_data_street, length: { maximum: 65 }
      validates :attorney_data_street_number, length: { maximum: 10 }
      validates :attorney_data_flat_number, length: { maximum: 10 }
      validates :attorney_data_city, length: { maximum: 56 }
      validates :attorney_data_zip_code, length: { maximum: 6 }
      validates :attorney_data_country,
                :attorney_data_voivodeship,
                :attorney_data_county,
                :attorney_data_community,
                :attorney_data_email,
                :attorney_data_epuap_delivery_address,
                length: { maximum: 100 }
      validates :attorney_data_phone_number, length: { maximum: 30 }
      validate :attorney_data_completeness
      validates :attorney_data_email,
                'valid_email_2/email': { disposable: false },
                if: ->(form) { form.attorney_data_email.present? }

      # validations for sub-section 7a
      validate :detailed_notes_length
      validate :detailed_notes_valid_json

      # validations for sub-section 7b
      validate :request_body_length

      # validations for section 8 - declaration remote correspondence
      validates :declaration_remote_correspondence, inclusion: { in: [true, false] }

      # validations for section 9 - attachments
      validates :attorney_power_represent_applicant_or_for_service, presence: true, if: :attorney_data?
      validates :attorney_power_represent_applicant_or_for_service, file_form: {
        max_size: 5.megabytes,
        acceptable_types: %w[
          image/jpg
          image/jpeg
          application/pdf
        ]
      }

      validates :attorney_power_payment_stamp_duty_confirm, file_form: {
        max_size: 5.megabytes,
        acceptable_types: %w[
          image/jpg
          image/jpeg
          application/pdf
        ]
      }

      validates :parcel_site_boundary, file_form: {
        max_size: 5.megabytes,
        acceptable_types: %w[
          image/jpg
          image/jpeg
          application/pdf
        ]
      }

      validates :files, file_form: {
        count: 2,
        max_size: 5.megabytes,
        acceptable_types:
          %w[
            image/jpg
            image/jpeg
            application/pdf
            application/msword
            application/vnd.openxmlformats-officedocument.wordprocessingml.document
            application/vnd.oasis.opendocument.text
            text/rtf
            application/vnd.ms-excel
            application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
            application/vnd.ms-powerpoint
            application/vnd.openxmlformats-officedocument.presentationml.presentation
          ]
      }

      # validations for additional section - optional email confirmation request
      validates :optional_confirmation_request, inclusion: { in: [true, false] }
      validates :email_confirmation_request,
                presence: true,
                'valid_email_2/email': { disposable: false },
                if: ->(form) { form.optional_confirmation_request? }


      # validations for last attrs
      validates :confirm_read_process_description, inclusion: { in: [true], message: 'Musi być zaznaczony' }

      private

      def submitter_full_name_or_org_name
        if submitter_data_role.to_s == Decidim::StudyNotes::StudyNote::INDIVIDUAL
          self.submitter_data_org_name = ''
        else
          self.submitter_data_first_name = ''
          self.submitter_data_last_name = ''
        end
      end

      def mailing_address_data_incomplete?
        mailing_address_attrs = [
          mailing_address_data_country,
          mailing_address_data_voivodeship,
          mailing_address_data_county,
          mailing_address_data_community,
          mailing_address_data_street,
          mailing_address_data_street_number,
          mailing_address_data_city,
          mailing_address_data_zip_code
        ]

        # Check if any of the attributes are present
        if mailing_address_attrs.any?(&:present?)
          # Ensure all attributes are present
          mailing_address_attrs.each_with_index do |attr, index|
            next unless attr.blank?

            errors.add(
              :base,
              'Wszystkie pola sekcji 5 dotyczącej adresu do korespondencji muszą zostać wypełnione,
                      jeśli zostało wypełnione choć jedno spośród tych pól'
            )
            break
          end
        end
      end

      def attorney_data_completeness
        attorney_attrs = [
          attorney_data_first_name,
          attorney_data_last_name,
          attorney_data_country,
          attorney_data_voivodeship,
          attorney_data_county,
          attorney_data_community,
          attorney_data_street,
          attorney_data_street_number,
          attorney_data_city,
          attorney_data_zip_code
        ]

        # Check if any of the attributes are present
        return unless attorney_attrs.any?(&:present?) || attorney_data_role.present?

        # Ensure all attributes are present
        if attorney_attrs.any?(&:blank?)
          errors.add(
            :base,
            "Wszystkie pola sekcji 6 oznaczone gwiazdką muszą zostać wypełnione, jeśli zostało wypełnione choć jedno z pól dotyczących pełnomocnika."
          )
        end

        # Ensure radio data role
        errors.add(:attorney_data_role, "Musisz wybrać rolę pełnomocnika.") if attorney_data_role.blank?
      end

      def attorney_data?
        attorney_data_role &&
          attorney_data_first_name &&
          attorney_data_last_name &&
          attorney_data_country &&
          attorney_data_voivodeship &&
          attorney_data_county &&
          attorney_data_community &&
          attorney_data_street &&
          attorney_data_street_number &&
          attorney_data_flat_number &&
          attorney_data_city &&
          attorney_data_zip_code
      end

      def request_body_length
        # count a new line as 1 char instead of 2
        return unless request_body.gsub(/\r\n/, "\n").length > 1000

        errors.add(
          :request_body,
          'jest za długie (maksymalnie 1000 znaków)'
        )
      end

      def detailed_notes_length
        return if detailed_notes.blank?

        begin
          details = JSON.parse(detailed_notes)

          details.each.with_index(1) do |entry, index|
            if entry['social_infrastructure_accessibility_body'].present? && entry['social_infrastructure_accessibility_body'].gsub(/\r\n/, "\n").length > 1000

            errors.add(
              :base,
              "#{I18n.t('activemodel.attributes.study_note.detailed_notes_social_infrastructure_accessibility_body')}
                w pozycji #{index} przekracza maksymalną długość 1000 znaków."
            )
          end
        end

        rescue JSON::ParserError => e
          errors.add(
            :base,
            'nie jest prawidłowym formatem danych'
          )
        end
      end 

      def detailed_notes_valid_json
        self.detailed_notes = '' if detailed_notes == '[]'
      end

      def sanitize_detailed_notes
        return if detailed_notes.blank?

        details = JSON.parse(detailed_notes)
        details.each do |entry|
          if entry["functional_profile"].to_s != "true"
            entry["functional_profile_area_id"] = nil
            entry["functional_profile_area_classes"] = []
          end

          if entry["area_parameters"].to_s != "true"
            entry["detailed_notes_area_parameters_max_height_intensity"] = nil
            entry["max_height_intensity"] = nil
            entry["detailed_notes_area_parameters_max_height_building"] = nil
            entry["max_height_building"] = nil
            entry["detailed_notes_area_parameters_max_percent_area"] = nil
            entry["max_percent_area"] = nil
            entry["detailed_notes_area_parameters_min_percent_bio"] = nil
            entry["min_percent_bio"] = nil
          end

          entry["infill_development_include"] = "false" if entry["infill_development"].to_s != "true"
          entry["inner_city_development_include"] = "false" if entry["inner_city_development"].to_s != "true"
          entry["social_infrastructure_accessibility_body"] = nil if entry["detailed_notes_social_infrastructure_accessibility"].to_s != "true"
        end

        self.detailed_notes = details.to_json
      end
    end
  end
end
