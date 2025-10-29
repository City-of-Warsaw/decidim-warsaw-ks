# frozen_string_literal: true

module Decidim
  module GeneralPlanRequests
    # A command with all the business logic when creating a General Plan Request
    class CreateGeneralPlanRequest < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        general_plan_request = create_general_plan_request
        register_to_signum(general_plan_request) unless Rails.env.development?
        send_notification(general_plan_request)
        broadcast(:ok, general_plan_request)
      end

      private

      attr_reader :form

      # Private method
      #
      # returns created general plan request
      def create_general_plan_request
        Decidim::GeneralPlanRequests::GeneralPlanRequest.create(general_plan_request_attributes)
      end

      def general_plan_request_attributes
        attrs_for_sections_1_2_3.merge(
          attrs_for_section_4_submitter_data,
          attrs_for_section_5_mailing_address_data,
          attrs_for_section_6_attorney_data,
          attrs_for_section_7_letter_content,
          attrs_for_section_8_declaration_remote_correspondence,
          attrs_for_section_9,
          attrs_for_additional_section,
          last_attrs
        )
      end

      def attrs_for_sections_1_2_3
        {
          authority_name_which_letter_is_addressed: form.authority_name_which_letter_is_addressed,
          letter_type: form.letter_type,
          urban_planning_act_type: form.urban_planning_act_type
        }
      end

      def attrs_for_section_4_submitter_data
        {
          submitter_data_role: form.submitter_data_role,
          submitter_data_first_name: form.submitter_data_first_name,
          submitter_data_last_name: form.submitter_data_last_name,
          submitter_data_org_name: form.submitter_data_org_name,
          submitter_data_country: form.submitter_data_country,
          submitter_data_voivodeship: form.submitter_data_voivodeship,
          submitter_data_county: form.submitter_data_county,
          submitter_data_community: form.submitter_data_community,
          submitter_data_street: form.submitter_data_street,
          submitter_data_street_number: form.submitter_data_street_number,
          submitter_data_flat_number: form.submitter_data_flat_number,
          submitter_data_city: form.submitter_data_city,
          submitter_data_zip_code: form.submitter_data_zip_code,
          submitter_data_email: form.submitter_data_email,
          submitter_data_phone_number: form.submitter_data_phone_number,
          submitter_data_epuap_delivery_address: form.submitter_data_epuap_delivery_address,
          perpetual_owner_of_the_property: form.perpetual_owner_of_the_property
        }
      end

      def attrs_for_section_5_mailing_address_data
        {
          mailing_address_data_country: form.mailing_address_data_country,
          mailing_address_data_voivodeship: form.mailing_address_data_voivodeship,
          mailing_address_data_county: form.mailing_address_data_county,
          mailing_address_data_community: form.mailing_address_data_community,
          mailing_address_data_street: form.mailing_address_data_street,
          mailing_address_data_street_number: form.mailing_address_data_street_number,
          mailing_address_data_flat_number: form.mailing_address_data_flat_number,
          mailing_address_data_city: form.mailing_address_data_city,
          mailing_address_data_zip_code: form.mailing_address_data_zip_code
        }
      end

      def attrs_for_section_6_attorney_data
        {
          attorney_data_role: form.attorney_data_role,
          attorney_data_first_name: form.attorney_data_first_name,
          attorney_data_last_name: form.attorney_data_last_name,
          attorney_data_country: form.attorney_data_country,
          attorney_data_voivodeship: form.attorney_data_voivodeship,
          attorney_data_county: form.attorney_data_county,
          attorney_data_community: form.attorney_data_community,
          attorney_data_street: form.attorney_data_street,
          attorney_data_street_number: form.attorney_data_street_number,
          attorney_data_flat_number: form.attorney_data_flat_number,
          attorney_data_city: form.attorney_data_city,
          attorney_data_zip_code: form.attorney_data_zip_code,
          attorney_data_email: form.attorney_data_email,
          attorney_data_phone_number: form.attorney_data_phone_number,
          attorney_data_epuap_delivery_address: form.attorney_data_epuap_delivery_address
        }
      end

      def attrs_for_section_7_letter_content
        {
          request_body: form.request_body,
          request_body_content_details: form.request_body_content_details,
          details_land_parcels_with_parameters: form.details_land_parcels_with_parameters
        }
      end

      def attrs_for_section_8_declaration_remote_correspondence
        {
          declaration_remote_correspondence: form.declaration_remote_correspondence
        }
      end

      def attrs_for_section_9
        {
          attorney_power_represent_applicant_or_for_service: form.attorney_power_represent_applicant_or_for_service,
          attorney_power_payment_stamp_duty_confirm: form.attorney_power_payment_stamp_duty_confirm,
          parcel_site_boundary: form.parcel_site_boundary,
          files: form.files,
          files_filename_one: form.files_filename_one,
          files_filename_two: form.files_filename_two
        }
      end

      def attrs_for_additional_section
        {
          optional_confirmation_request: form.optional_confirmation_request,
          email_confirmation_request: form.email_confirmation_request
        }
      end

      def last_attrs
        {
          confirm_read_process_description: form.confirm_read_process_description,
          confirm_process_personal_data: form.confirm_process_personal_data,
          component: form.current_component
        }
      end

      # Rejestruje pismo korzystajac ze stalego urz_id
      def register_to_signum(general_plan_request)
        Decidim::SignumService.new.register_general_plan_request_to_signum(
          general_plan_request: general_plan_request,
          user: current_user
        )
      end

      def send_notification(general_plan_request)
        if general_plan_request.component.admin_email.present?
          Decidim::CoreExtended::TemplatedMailerJob.perform_later(
            'create_general_plan_request_confirmation_to_admin',
            {
              resource: general_plan_request,
              anonymize_pdf: true
            }
          )
        end

        if general_plan_request.email_confirmation_request.present?
          Decidim::CoreExtended::TemplatedMailerJob.perform_later(
            'create_general_plan_request_confirmation_to_submitter',
            {
              resource: general_plan_request,
              anonymize_pdf: false
            }
          )
        end
      end
    end
  end
end
