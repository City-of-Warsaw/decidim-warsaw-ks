# frozen_string_literal: true

module Decidim
  module GeneralPlanRequests
    class GeneralPlanRequestSerializer < Decidim::Exporters::Serializer
      include Decidim::GeneralPlanRequests::GeneralPlanRequestHelper

      def initialize; end

      def headers
        columns_order.map { |column| columns_definition[column][:name] }
      end

      # Public: Get the order of columns for serializing a general plan request.
      # Returns an Array of symbols representing the column order.
      def columns_order
        @columns_order ||= %i[
          lp
          id
          authority_name_which_letter_is_addressed
          letter_type
          urban_planning_act_type
          submitter_data_role
          submitter_data_first_name
          submitter_data_last_name
          submitter_data_org_name
          submitter_data_country
          submitter_data_voivodeship
          submitter_data_county
          submitter_data_community
          submitter_data_street
          submitter_data_street_number
          submitter_data_flat_number
          submitter_data_city
          submitter_data_zip_code
          submitter_data_email
          submitter_data_phone_number
          submitter_data_epuap_delivery_address
          perpetual_owner_of_the_property
          mailing_address_data_country
          mailing_address_data_voivodeship
          mailing_address_data_county
          mailing_address_data_community
          mailing_address_data_street
          mailing_address_data_street_number
          mailing_address_data_flat_number
          mailing_address_data_city
          mailing_address_data_zip_code
          attorney_data_role
          attorney_data_first_name
          attorney_data_last_name
          attorney_data_country
          attorney_data_voivodeship
          attorney_data_county
          attorney_data_community
          attorney_data_street
          attorney_data_street_number
          attorney_data_flat_number
          attorney_data_city
          attorney_data_zip_code
          attorney_data_email
          attorney_data_phone_number
          attorney_data_epuap_delivery_address
          request_body
          content_details_name
          content_details_parcel_id
          content_details_is_record_area_included
          content_details_body
          details_land_parcels_name
          details_land_parcels_parcel_id
          details_land_parcels_is_record_area_included
          details_land_parcels_area_class_name
          details_land_parcels_max_percent_area
          details_land_parcels_max_height_building
          details_land_parcels_min_percent_bio
          declaration_remote_correspondence
          attorney_power_represent_applicant_or_for_service
          attorney_power_payment_stamp_duty_confirm
          parcel_site_boundary
          files
          optional_confirmation_request
          email_confirmation_request
          confirm_read_process_description
          confirm_process_personal_data
        ]
      end

      def columns_definition
        @columns_definition ||= {
          lp: {
            name: column_name_translation('lp'),
            size: :auto,
            alignment: :right
          },
          id: { name: column_name_translation('id'), size: :auto },

          # attrs for sections 1, 2, 3
          authority_name_which_letter_is_addressed: { name: column_name_translation('authority_name_which_letter_is_addressed'), size: :auto },
          letter_type: { name: column_name_translation('letter_type'), size: :auto },
          urban_planning_act_type: { name: column_name_translation('urban_planning_act_type'), size: :auto },

          # attrs for section 4 - submitter data
          submitter_data_role: { name: column_name_translation('submitter_data_role'), size: :auto },
          submitter_data_first_name: { name: column_name_translation('submitter_data_first_name'), size: :auto },
          submitter_data_last_name: { name: column_name_translation('submitter_data_last_name'), size: :auto },
          submitter_data_org_name: { name: column_name_translation('submitter_data_org_name'), size: :auto },
          submitter_data_country: { name: column_name_translation('submitter_data_country'), size: :auto },
          submitter_data_voivodeship: { name: column_name_translation('submitter_data_voivodeship'), size: :auto },
          submitter_data_county: { name: column_name_translation('submitter_data_county'), size: :auto },
          submitter_data_community: { name: column_name_translation('submitter_data_community'), size: :auto },
          submitter_data_street: { name: column_name_translation('submitter_data_street'), size: :auto },
          submitter_data_street_number: { name: column_name_translation('submitter_data_street_number'), size: :auto },
          submitter_data_flat_number: { name: column_name_translation('submitter_data_flat_number'), size: :auto },
          submitter_data_city: { name: column_name_translation('submitter_data_city'), size: :auto },
          submitter_data_zip_code: { name: column_name_translation('submitter_data_zip_code'), size: :auto },
          submitter_data_email: { name: column_name_translation('submitter_data_email'), size: :auto },
          submitter_data_phone_number: { name: column_name_translation('submitter_data_phone_number'), size: :auto },
          submitter_data_epuap_delivery_address: { name: column_name_translation('submitter_data_epuap_delivery_address'), size: :auto },
          perpetual_owner_of_the_property: { name: column_name_translation('perpetual_owner_of_the_property'), size: :auto },

          # attrs for section 5 - mailing address data
          mailing_address_data_country: { name: column_name_translation('mailing_address_data_country'), size: :auto },
          mailing_address_data_voivodeship: { name: column_name_translation('mailing_address_data_country'), size: :auto },
          mailing_address_data_county: { name: column_name_translation('mailing_address_data_county'), size: :auto },
          mailing_address_data_community: { name: column_name_translation('mailing_address_data_community'), size: :auto },
          mailing_address_data_street: { name: column_name_translation('mailing_address_data_street'), size: :auto },
          mailing_address_data_street_number: { name: column_name_translation('mailing_address_data_street_number'), size: :auto },
          mailing_address_data_flat_number: { name: column_name_translation('mailing_address_data_flat_number'), size: :auto },
          mailing_address_data_city: { name: column_name_translation('mailing_address_data_city'), size: :auto },
          mailing_address_data_zip_code: { name: column_name_translation('mailing_address_data_zip_code'), size: :auto },

          # attrs for section 6 - attorney data
          attorney_data_role: { name: column_name_translation('attorney_data_role'), size: :auto },
          attorney_data_first_name: { name: column_name_translation('attorney_data_first_name'), size: :auto },
          attorney_data_last_name: { name: column_name_translation('attorney_data_last_name'), size: :auto },
          attorney_data_country: { name: column_name_translation('attorney_data_country'), size: :auto },
          attorney_data_voivodeship: { name: column_name_translation('attorney_data_voivodeship'), size: :auto },
          attorney_data_county: { name: column_name_translation('attorney_data_county'), size: :auto },
          attorney_data_community: { name: column_name_translation('attorney_data_community'), size: :auto },
          attorney_data_street: { name: column_name_translation('attorney_data_street'), size: :auto },
          attorney_data_street_number: { name: column_name_translation('attorney_data_street_number'), size: :auto },
          attorney_data_flat_number: { name: column_name_translation('attorney_data_flat_number'), size: :auto },
          attorney_data_city: { name: column_name_translation('attorney_data_city'), size: :auto },
          attorney_data_zip_code: { name: column_name_translation('attorney_data_zip_code'), size: :auto },
          attorney_data_email: { name: column_name_translation('attorney_data_email'), size: :auto },
          attorney_data_phone_number: { name: column_name_translation('attorney_data_phone_number'), size: :auto },
          attorney_data_epuap_delivery_address: { name: column_name_translation('attorney_data_epuap_delivery_address'), size: :auto },

          # attrs for section 7 - letter content
          request_body: {
            name: column_name_translation('request_body'),
            size: :body,
            wrap_text: true
          },

          # split json request_body_content_details for section 7.2
          content_details_name: { name: column_name_translation('content_details_name'), size: :auto },
          content_details_parcel_id: { name: column_name_translation('content_details_parcel_id'), size: :auto },
          content_details_is_record_area_included: { name: column_name_translation('content_details_is_record_area_included'), size: :auto },
          content_details_body: {
            name: column_name_translation('content_details_body'),
            size: :body,
            wrap_text: true
          },

          # split json details_land_parcels_with_parameters for section 7.3
          details_land_parcels_name: { name: column_name_translation('details_land_parcels_name'), size: :auto },
          details_land_parcels_parcel_id: { name: column_name_translation('details_land_parcels_parcel_id'), size: :auto },
          details_land_parcels_is_record_area_included: { name: column_name_translation('details_land_parcels_is_record_area_included'), size: :auto },
          details_land_parcels_area_class_name: { name: column_name_translation('details_land_parcels_area_class_name'), size: :auto },
          details_land_parcels_max_percent_area: { name: column_name_translation('details_land_parcels_max_percent_area'), size: :auto },
          details_land_parcels_max_height_building: { name: column_name_translation('details_land_parcels_max_height_building'), size: :auto },
          details_land_parcels_min_percent_bio: { name: column_name_translation('details_land_parcels_min_percent_bio'), size: :auto },

          # attrs for section 8 - declaration remote correspondence
          declaration_remote_correspondence: { name: column_name_translation('declaration_remote_correspondence'), size: :auto },

          # attrs for section 9 - attachments
          attorney_power_represent_applicant_or_for_service: {
            name: column_name_translation('attorney_power_represent_applicant_or_for_service'),
            size: :url,
            wrap_text: true,
            hyperlink: true
          },
          attorney_power_payment_stamp_duty_confirm: {
            name: column_name_translation('attorney_power_payment_stamp_duty_confirm'),
            size: :url,
            wrap_text: true,
            hyperlink: true
          },
          parcel_site_boundary: {
            name: column_name_translation('parcel_site_boundary'),
            size: :url,
            wrap_text: true,
            hyperlink: true
          },
          files: {
            name: column_name_translation('files'),
            size: :url,
            wrap_text: true,
            hyperlink: true
          },

          # attrs for additional section - optional email confirmation request
          optional_confirmation_request: { name: column_name_translation('optional_confirmation_request'), size: :auto },
          email_confirmation_request: { name: column_name_translation('email_confirmation_request'), size: :auto },

          # last attrs
          confirm_read_process_description: { name: column_name_translation('confirm_read_process_description'), size: :auto },
          confirm_process_personal_data: { name: column_name_translation('confirm_process_personal_data') }
        }
      end

      def columns_widths
        columns_order.map { |column| column_width(columns_definition[column][:size]) }
      end

      def wrap_text_columns
        columns_order.map { |column| columns_definition[column][:wrap_text] ? true : false }
      end

      def url_columns
        @url_columns ||= columns_order.select { |column| columns_definition[column][:hyperlink] == true }
      end

      def column_alignment(column)
        columns_definition[column][:alignment]
      end


      # Public: Serializes an array of general plan requests into an array of serialized hashes,
      #
      # @param gpr [Array] An array of general plan request objects to serialize.
      # @return [Array] An array of serialized general plan request hashes
      def serialize_all_with_json(gpr)
        gpr.flat_map.with_index(1) do |gpr, index|
          serialize_for_json(gpr, index)
        end
      end

      # Serializes a general plan request into a hash, create additional hash objects for any json
      #
      # @param gpr [Object] The general plan request object to serialize.
      # @param index [Integer] The index of the general plan request in the array.
      # @return [Hash] for serialized general plan request hash without json,
      # or [Array] of hashes for general plan request hash with json
      def serialize_for_json(gpr, index)
        if gpr.request_body_content_details.present? && gpr.details_land_parcels_with_parameters.present?
          request_details = json_parse_request_body_content_details(gpr, index, 1)
          land_parcels = json_parse_details_land_parcels_with_parameters(gpr, index, 2)
          request_details + land_parcels
        elsif gpr.request_body_content_details.present?
          json_parse_request_body_content_details(gpr, index, 1)
        elsif gpr.details_land_parcels_with_parameters.present?
          json_parse_details_land_parcels_with_parameters(gpr, index, 1)
        else
          general_plan_request_attrs(gpr, index)
        end
      end

      # Parses the JSON content details of a general plan request and serializes it into a collection of hashes.
      #
      # @param gpr [Object] The general plan request object containing the JSON data to parse.
      # @param parent_index [Integer] The parent index of the general plan request in the array.
      # @param index [Integer] The index used for numbering the content details within the parent index.
      # @return [Array<Hash>] An array of hashes, each representing a serialized content detail entry from the JSON.
      def json_parse_request_body_content_details(gpr, parent_index, index)
        JSON.parse(gpr.request_body_content_details).each.with_index(1).map do |json, subindex|
          general_plan_request_attrs(gpr, "#{parent_index}.#{index}.#{subindex}").tap do |attrs|
            attrs[:content_details_name] = json['name']
            attrs[:content_details_parcel_id] = json['parcel_id']
            attrs[:content_details_is_record_area_included] = (
              json['is_record_area_included'] == 'true' ? 'Tak' : 'Nie'
            )
            attrs[:content_details_body] = json['body']
          end
        end
      end

      # Parses the JSON details of land parcels with parameters from a general plan request and serializes it into a collection of hashes.
      #
      # @param gpr [Object] The general plan request object containing the JSON data for land parcels.
      # @param parent_index [Integer] The parent index of the general plan request in the array.
      # @param index [Integer] The index used for numbering the land parcels within the parent index.
      # @return [Array<Hash>] An array of hashes, each representing a serialized land parcel entry from the JSON.
      def json_parse_details_land_parcels_with_parameters(gpr, parent_index, index)
        JSON.parse(gpr.details_land_parcels_with_parameters).each.with_index(1).map do |json, subindex|
          general_plan_request_attrs(gpr, "#{parent_index}.#{index}.#{subindex}").tap do |attrs|
            attrs[:details_land_parcels_name] = json['name']
            attrs[:details_land_parcels_parcel_id] = json['parcel_id']
            attrs[:details_land_parcels_is_record_area_included] = (
              json['is_record_area_included'] == 'true' ? 'Tak' : 'Nie'
            )
            attrs[:details_land_parcels_area_class_name] = json['area_class_name']
            attrs[:details_land_parcels_max_percent_area] = json['max_percent_area']
            attrs[:details_land_parcels_max_height_building] = json['max_height_building']
            attrs[:details_land_parcels_min_percent_bio] = json['min_percent_bio']
          end
        end
      end

      # Serializes a general plan request object into a hash, with optional additional attributes.
      #
      # @param gpr [Object] The general plan request object to serialize.
      # @param index [Integer] The index of the general plan request in the array.
      # @return [Hash] The serialized general plan request hash.
      def general_plan_request_attrs(gpr, index)
        {
          lp: index,
          id: gpr.id,

          # attrs for sections 1, 2, 3
          authority_name_which_letter_is_addressed: gpr.authority_name_which_letter_is_addressed,
          letter_type: letter_type(gpr),
          urban_planning_act_type: urban_planning_act_type(gpr),

          # attrs for section 4 - submitter data
          submitter_data_role: submitter_data_role(gpr),
          submitter_data_first_name: gpr.submitter_data_first_name,
          submitter_data_last_name: gpr.submitter_data_last_name,
          submitter_data_org_name: gpr.submitter_data_org_name,
          submitter_data_country: gpr.submitter_data_country,
          submitter_data_voivodeship: gpr.submitter_data_voivodeship,
          submitter_data_county: gpr.submitter_data_county,
          submitter_data_community: gpr.submitter_data_community,
          submitter_data_street: gpr.submitter_data_street,
          submitter_data_street_number: gpr.submitter_data_street_number,
          submitter_data_flat_number: gpr.submitter_data_flat_number,
          submitter_data_city: gpr.submitter_data_city,
          submitter_data_zip_code: gpr.submitter_data_zip_code,
          submitter_data_email: gpr.submitter_data_email,
          submitter_data_phone_number: gpr.submitter_data_phone_number,
          submitter_data_epuap_delivery_address: gpr.submitter_data_epuap_delivery_address,
          perpetual_owner_of_the_property: perpetual_owner_of_the_property(gpr),

          # attrs for section 5 - mailing address data
          mailing_address_data_country: gpr.mailing_address_data_country,
          mailing_address_data_voivodeship: gpr.mailing_address_data_voivodeship,
          mailing_address_data_county: gpr.mailing_address_data_county,
          mailing_address_data_community: gpr.mailing_address_data_community,
          mailing_address_data_street: gpr.mailing_address_data_street,
          mailing_address_data_street_number: gpr.mailing_address_data_street_number,
          mailing_address_data_flat_number: gpr.mailing_address_data_flat_number,
          mailing_address_data_city: gpr.mailing_address_data_city,
          mailing_address_data_zip_code: gpr.mailing_address_data_zip_code,

          # attrs for section 6 - attorney data
          attorney_data_role: attorney_data_role(gpr),
          attorney_data_first_name: gpr.attorney_data_first_name,
          attorney_data_last_name: gpr.attorney_data_last_name,
          attorney_data_country: gpr.attorney_data_country,
          attorney_data_voivodeship: gpr.attorney_data_voivodeship,
          attorney_data_county: gpr.attorney_data_county,
          attorney_data_community: gpr.attorney_data_community,
          attorney_data_street: gpr.attorney_data_street,
          attorney_data_street_number: gpr.attorney_data_street_number,
          attorney_data_flat_number: gpr.attorney_data_flat_number,
          attorney_data_city: gpr.attorney_data_city,
          attorney_data_zip_code: gpr.attorney_data_zip_code,
          attorney_data_email: gpr.attorney_data_email,
          attorney_data_phone_number: gpr.attorney_data_phone_number,
          attorney_data_epuap_delivery_address: gpr.attorney_data_epuap_delivery_address,

          # attrs for section 7 - letter content
          request_body: gpr.request_body,

          # split json request_body_content_details for section 7.2
          content_details_name: nil,
          content_details_parcel_id: nil,
          content_details_is_record_area_included: nil,
          content_details_body: nil,

          # split json details_land_parcels_with_parameters for section 7.3
          details_land_parcels_name: nil,
          details_land_parcels_parcel_id: nil,
          details_land_parcels_is_record_area_included: nil,
          details_land_parcels_area_class_name: nil,
          details_land_parcels_max_percent_area: nil,
          details_land_parcels_max_height_building: nil,
          details_land_parcels_min_percent_bio: nil,

          # attrs for section 8 - declaration remote correspondence
          declaration_remote_correspondence: declaration_remote_correspondence(gpr),

          # attrs for section 9 - attachments
          attorney_power_represent_applicant_or_for_service: attorney_power_represent_applicant_or_for_service_url(gpr),
          attorney_power_payment_stamp_duty_confirm: attorney_power_payment_stamp_duty_confirm_url(gpr),
          parcel_site_boundary: parcel_site_boundary_url(gpr),
          files: attachments_urls(gpr),

          # attrs for additional section - optional email confirmation request
          optional_confirmation_request: optional_confirmation_request(gpr),
          email_confirmation_request: gpr.email_confirmation_request,

          # last attrs
          confirm_read_process_description: confirm_read_process_description?(gpr),
          confirm_process_personal_data: confirm_process_personal_data?(gpr)
        }
      end

      # Returns an array of values from the given attributes hash,
      # in the order specified by the columns_order method.
      #
      # @param attrs [Hash] The general_plan_request attributes hash
      # @return [Array] serialized array from general_plan_request attrs
      def ordered_values(attrs)
        columns_order.map { |column| attrs[column] }
      end

      private

      def column_name_translation(column)
        I18n.t(column, scope: 'decidim.general_plan_requests.export.general_plan_request')
      end

      def column_width(key)
        case key
        when :auto then nil
        when :idx then 5
        when :body then 100
        when :url then 60
        else
          30
        end
      end

      def file_url(file, general_plan_request)
        Rails.application.routes.url_helpers.rails_blob_url(
          file,
          host: general_plan_request.organization.host
        )
      end

      def attorney_power_represent_applicant_or_for_service_url(gpr)
        if gpr.attorney_power_represent_applicant_or_for_service.attached?
          file_url(gpr.attorney_power_represent_applicant_or_for_service, gpr)
        else
          ''
        end
      end

      def attorney_power_payment_stamp_duty_confirm_url(gpr)
        if gpr.attorney_power_payment_stamp_duty_confirm.attached?
          file_url(gpr.attorney_power_payment_stamp_duty_confirm, gpr)
        else
          ''
        end
      end

      def parcel_site_boundary_url(gpr)
        if gpr.parcel_site_boundary.attached?
          file_url(gpr.parcel_site_boundary, gpr)
        else
          ''
        end
      end

      def attachments_urls(gpr)
        gpr.files.each_with_index.map do |file, index|
          "#{index + 1}.#{file_url(file, gpr)}"
        end.join(', ')
      end

      def letter_type(gpr)
        I18n.t(
          "decidim.general_plan_requests.export.general_plan_request.letter_type_enum.#{gpr.letter_type}"
        )
      end

      def urban_planning_act_type(gpr)
        I18n.t(
          "decidim.general_plan_requests.export.general_plan_request.urban_planning_act_type_enum.#{gpr.urban_planning_act_type}"
        )
      end

      def submitter_data_role(gpr)
        if gpr.submitter_data_role == Decidim::GeneralPlanRequests::GeneralPlanRequest::INDIVIDUAL
          I18n.t('decidim.general_plan_requests.export.general_plan_request.submitter_role_person')
        else
          I18n.t('decidim.general_plan_requests.export.general_plan_request.submitter_role_organization')
        end
      end

      def perpetual_owner_of_the_property(gpr)
        if gpr.perpetual_owner_of_the_property
          I18n.t('decidim.general_plan_requests.export.general_plan_request.boolean_yes')
        else
          I18n.t('decidim.general_plan_requests.export.general_plan_request.boolean_no')
        end
      end

      def attorney_data_role(gpr)
        if gpr.attorney_data_role == Decidim::GeneralPlanRequests::GeneralPlanRequest::INDIVIDUAL
          I18n.t('decidim.general_plan_requests.export.general_plan_request.attorney_role_all')
        else
          I18n.t('decidim.general_plan_requests.export.general_plan_request.attorney_role_delivery')
        end
      end

      def declaration_remote_correspondence(gpr)
        if gpr.declaration_remote_correspondence
          I18n.t('decidim.general_plan_requests.export.general_plan_request.boolean_yes')
        else
          I18n.t('decidim.general_plan_requests.export.general_plan_request.boolean_no')
        end
      end

      def optional_confirmation_request(gpr)
        if gpr.optional_confirmation_request
          I18n.t('decidim.general_plan_requests.export.general_plan_request.boolean_yes')
        else
          I18n.t('decidim.general_plan_requests.export.general_plan_request.boolean_no')
        end
      end

      def confirm_read_process_description?(gpr)
        if gpr.confirm_read_process_description
          I18n.t('decidim.general_plan_requests.export.general_plan_request.boolean_yes')
        else
          I18n.t('decidim.general_plan_requests.export.general_plan_request.boolean_no')
        end
      end

      def confirm_process_personal_data?(gpr)
        if gpr.confirm_read_process_description
          I18n.t('decidim.general_plan_requests.export.general_plan_request.boolean_yes')
        else
          I18n.t('decidim.general_plan_requests.export.general_plan_request.boolean_no')
        end
      end
    end
  end
end
