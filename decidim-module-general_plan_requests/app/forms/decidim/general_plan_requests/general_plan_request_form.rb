# frozen_string_literal: true

require 'valid_email2'
require 'obscenity/active_model'
require_dependency 'file_form_validator'

module Decidim
  module GeneralPlanRequests
    # This class holds a Form to create single general plan request for process component.
    class GeneralPlanRequestForm < Decidim::Form
      include ActionView::Helpers::UrlHelper
      include Decidim::GeneralPlanRequests::GeneralPlanRequestHelper

      mimic :general_plan_request

      # ATTRIBUTES:

      # attrs for sections 1, 2, 3
      attribute :authority_name_which_letter_is_addressed, String, default: 'Prezydent m.st. Warszawy'
      attribute :letter_type, Integer, default: 0
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

      # attrs for section 7 - letter content
      attribute :request_body, String

      # attrs for sub-section 7.2
      attribute :request_body_content_details, Hash, default: nil

      # attrs for sub-section 7.3
      attribute :details_land_parcels_with_parameters, Hash, default: nil

      # attrs for section 8 - declaration remote correspondence
      attribute :declaration_remote_correspondence, Boolean

      # attrs for section 9 - attachments
      attribute :attorney_power_represent_applicant_or_for_service
      attribute :attorney_power_payment_stamp_duty_confirm
      attribute :parcel_site_boundary
      attribute :files
      attribute :files_filename_one # also migrated
      attribute :files_filename_two # also migrated

      # attrs for additional section - optional email confirmation request
      attribute :optional_confirmation_request, Boolean
      attribute :email_confirmation_request, String

      # last attrs
      attribute :confirm_read_process_description, Boolean
      attribute :confirm_process_personal_data, Boolean, default: false

      # VALIDATIONS:

      # validations for section 4 - submitter data
      validates :submitter_data_role, presence: true
      validates :submitter_data_first_name,
                presence: true,
                if: ->(form) {
                  form.submitter_data_role == Decidim::GeneralPlanRequests::GeneralPlanRequest::INDIVIDUAL
                }
      validates :submitter_data_last_name,
                presence: true,
                if: ->(form) {
                  form.submitter_data_role == Decidim::GeneralPlanRequests::GeneralPlanRequest::INDIVIDUAL
                }
      validates :submitter_data_org_name,
                presence: true,
                if: ->(form) {
                  form.submitter_data_role == Decidim::GeneralPlanRequests::GeneralPlanRequest::ORGANIZATION
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
      validates :submitter_data_org_name, length: { maximum: 300 }
      validates :submitter_data_first_name,
                :submitter_data_last_name,
                :submitter_data_country,
                :submitter_data_voivodeship,
                :submitter_data_county,
                :submitter_data_community,
                :submitter_data_street,
                :submitter_data_city,
                :submitter_data_zip_code,
                :submitter_data_email,
                :submitter_data_epuap_delivery_address,
                length: { maximum: 100 }
      validates :submitter_data_street_number,
                :submitter_data_flat_number,
                length: { maximum: 20 }
      validates :submitter_data_phone_number, length: { maximum: 30 }
      validates :submitter_data_email,
                'valid_email_2/email': { disposable: false },
                if: ->(form) { form.submitter_data_email.present? }
      validates :perpetual_owner_of_the_property, inclusion: { in: [true, false] }

      # validations for section 5 - mailing address data
      validates :mailing_address_data_country,
                :mailing_address_data_voivodeship,
                :mailing_address_data_county,
                :mailing_address_data_community,
                :mailing_address_data_street,
                :mailing_address_data_city,
                :mailing_address_data_zip_code,
                length: { maximum: 100 }
      validates :mailing_address_data_street_number,
                :mailing_address_data_flat_number,
                length: { maximum: 20 }
      validate :mailing_address_data_incomplete?

      # validations for section 6 - attorney data
      validates :attorney_data_first_name,
                :attorney_data_last_name,
                :attorney_data_country,
                :attorney_data_voivodeship,
                :attorney_data_county,
                :attorney_data_community,
                :attorney_data_street,
                :attorney_data_city,
                :attorney_data_zip_code,
                :attorney_data_email,
                :attorney_data_epuap_delivery_address,
                length: { maximum: 100 }
      validates :attorney_data_street_number,
                :attorney_data_flat_number,
                length: { maximum: 20 }
      validates :attorney_data_phone_number, length: { maximum: 30 }
      validate :attorney_data_incomplete?
      validates :attorney_data_email,
                'valid_email_2/email': { disposable: false },
                if: ->(form) { form.attorney_data_email.present? }

      # validations for section 7 - letter content
      validates :request_body, presence: true
      validate :request_body_length

      # validations for sub-section 7.2
      validate :request_body_content_details_length
      validate :request_body_content_details_valid_json

      # validations for sub-section 7.3
      validate :details_land_parcels_with_parameters_length
      validate :details_land_parcels_with_parameters_length_valid_json

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
        if submitter_data_role == Decidim::GeneralPlanRequests::GeneralPlanRequest::INDIVIDUAL
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

      def attorney_data_incomplete?
        attorney_attrs = [
          attorney_data_role,
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
        if attorney_attrs.any?(&:present?)
          # Ensure all attributes are present
          attorney_attrs.each_with_index do |attr, index|
            next unless attr.blank?

            errors.add(
              :base,
              'Wszystkie pola sekcji 6 dotyczących danych pełnomocnika muszą zostać wypełnione,
                      jeśli zostało wypełnione choć jedno spośród tych pól'
            )
            break
          end
        end
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

      def request_body_content_details_length
        return if request_body_content_details.blank?

        begin
          details = JSON.parse(request_body_content_details)

          details.each.with_index(1) do |entry, index|
            if entry['parcel_id'].present? && entry['parcel_id'].length > 900
              errors.add(
                :base,
                "#{I18n.t('activemodel.attributes.general_plan_request.request_body_content_details_parcel_id')}
                 w pozycji #{index} przekracza maksymalną długość 900 znaków."
              )
            end

            next unless entry['body'].present? &&
                        entry['body'].gsub(/\r\n/, "\n").length > 1000

            errors.add(
              :base,
              "#{I18n.t('activemodel.attributes.general_plan_request.request_body_content_details_body')}
               w pozycji #{index} przekracza maksymalną długość 1000 znaków."
            )
          end

        rescue JSON::ParserError => e
          errors.add(
            :base,
            'nie jest prawidłowym formatem danych'
          )
        end
      end

      def details_land_parcels_with_parameters_length
        return if details_land_parcels_with_parameters.blank?

        begin
          details = JSON.parse(details_land_parcels_with_parameters)

          details.each.with_index(1) do |entry, index|
            if entry['parcel_id'].present? && entry['parcel_id'].length > 900
              errors.add(
                :base,
                "#{I18n.t('activemodel.attributes.general_plan_request.details_land_parcels_with_parameters_parcel_id')}
                 w pozycji #{index} przekracza maksymalną długość 900 znaków."
              )
            end

            next unless entry['area_class_name'].present? &&
                        entry['area_class_name'].gsub(/\r\n/, "\n").length > 900

            errors.add(
              :base,
              "#{I18n.t('activemodel.attributes.general_plan_request.details_land_parcels_with_parameters_area_class_name')}
               w pozycji #{index} przekracza maksymalną długość 900 znaków."
            )
          end

        rescue JSON::ParserError => e
          errors.add(
            :base,
            'nie jest prawidłowym formatem danych'
          )
        end
      end

      def request_body_content_details_valid_json
        self.request_body_content_details = '' if request_body_content_details == '[]'
      end

      def details_land_parcels_with_parameters_length_valid_json
        self.details_land_parcels_with_parameters = '' if details_land_parcels_with_parameters == '[]'
      end
    end
  end
end
