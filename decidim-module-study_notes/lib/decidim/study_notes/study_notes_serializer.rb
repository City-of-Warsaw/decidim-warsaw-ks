# frozen_string_literal: true

module Decidim
  module StudyNotes
    class StudyNotesSerializer < Decidim::Exporters::Serializer
      include Decidim::StudyNotes::StudyNotesHelper
      include Decidim::CoreExtended::SerializerExportHelper

      def initialize(resource = nil)
        super(resource)
      end

      # Public: Get the order of columns for serializing a study note.
      # Returns an Array of symbols representing the column order.
      def columns_order
        @columns_order ||= [
          :lp,
          :id,
          :sequential_number,
          :sequence,
          :created_at,
          :submitter_data_role,
          :submitter_data_first_name,
          :submitter_data_last_name,
          :submitter_data_org_name,
          :submitter_data_street,
          :submitter_data_street_number,
          :submitter_data_flat_number,
          :submitter_data_city,
          :submitter_data_zip_code,
          :perpetual_owner_of_the_property,
          :attorney_role_all,
          :attorney_role_delivery,
          :attorney_data_first_name,
          :attorney_data_last_name,
          :detailed_notes_parcel_ids,
          :detailed_notes_is_record_area_included,
          :detailed_note_functional_profile_area,
          :detailed_note_functional_profile_area_class,
          :detailed_notes_area_parameters_max_height_intensity,
          :detailed_notes_area_parameters_max_height_building,
          :detailed_notes_area_parameters_max_percent_area,
          :detailed_notes_area_parameters_min_percent_bio,
          :detailed_notes_infill_development,
          :detailed_notes_inner_city_development,
          :detailed_notes_social_infrastructure_accessibility_body,
          :request_body,
          :attorney_power_represent_applicant_or_for_service_attachment,
          :attorney_power_payment_stamp_duty_confirm_attachment,
          :detailed_notes_parcel_site_boundary_attachment,
          :files_file_one,
          :files_file_two
        ]
      end

      def columns_definition
        @columns_definition ||= {
          lp: {
            name: column_name_translation("lp"),
            size: :auto,
            alignment: :right
          },
          id: { name: column_name_translation("id"), size: :auto },
          sequential_number: { name: column_name_translation("sequential_number"), size: :auto },
          sequence: { name: column_name_translation("sequence"), size: :auto },
          created_at: { name: column_name_translation("created_at"), size: :auto },

          # attrs for section 4 - submitter data
          submitter_data_role: { name: column_name_translation("submitter_data_role"), size: :auto },
          submitter_data_first_name: { name: column_name_translation("submitter_data_first_name"), size: :auto },
          submitter_data_last_name: { name: column_name_translation("submitter_data_last_name"), size: :auto },
          submitter_data_org_name: { name: column_name_translation("submitter_data_org_name"), size: :auto },
          submitter_data_street: { name: column_name_translation("submitter_data_street"), size: :auto },
          submitter_data_street_number: { name: column_name_translation("submitter_data_street_number"), size: :auto },
          submitter_data_flat_number: { name: column_name_translation("submitter_data_flat_number"), size: :auto },
          submitter_data_city: { name: column_name_translation("submitter_data_city"), size: :auto },
          submitter_data_zip_code: { name: column_name_translation("submitter_data_zip_code"), size: :auto },
          perpetual_owner_of_the_property: { name: column_name_translation("perpetual_owner_of_the_property"), size: :auto },

          # attrs for section 6 - attorney data
          attorney_role_all: { name: column_name_translation("attorney_role_all"), size: :auto },
          attorney_role_delivery: { name: column_name_translation("attorney_role_delivery"), size: :auto },
          attorney_data_first_name: { name: column_name_translation("attorney_data_first_name"), size: :auto },
          attorney_data_last_name: { name: column_name_translation("attorney_data_last_name"), size: :auto },

          # split json request_body_content_details for section 7a
          detailed_notes_parcel_ids: { name: column_name_translation("detailed_notes_parcel_ids"), size: :auto },
          detailed_notes_is_record_area_included: { name: column_name_translation("detailed_notes_is_record_area_included"), size: :auto },
          detailed_note_functional_profile_area: { name: column_name_translation("detailed_note_functional_profile_area"), size: :auto },
          detailed_note_functional_profile_area_class: {
            name: column_name_translation("detailed_note_functional_profile_area_class"),
            size: :body,
            wrap_text: true
          },
          detailed_notes_area_parameters_max_height_intensity: { name: column_name_translation("detailed_notes_area_parameters_max_height_intensity"), size: :auto },
          detailed_notes_area_parameters_max_height_building: { name: column_name_translation("detailed_notes_area_parameters_max_height_building"), size: :auto },
          detailed_notes_area_parameters_max_percent_area: { name: column_name_translation("detailed_notes_area_parameters_max_percent_area"), size: :auto },
          detailed_notes_area_parameters_min_percent_bio: { name: column_name_translation("detailed_notes_area_parameters_min_percent_bio"), size: :auto },
          detailed_notes_infill_development: { name: column_name_translation("detailed_notes_infill_development"), size: :auto },
          detailed_notes_inner_city_development: { name: column_name_translation("detailed_notes_inner_city_development"), size: :auto },
          detailed_notes_social_infrastructure_accessibility_body: { name: column_name_translation("detailed_notes_social_infrastructure_accessibility_body"), size: :auto },

          # attrs for section 7b - request body
          request_body: {
            name: column_name_translation("request_body"),
            size: :body,
            wrap_text: true
          },

          # attachments for section 6 - attorney data
          attorney_power_represent_applicant_or_for_service_attachment: {
            name: column_name_translation("attorney_power_represent_applicant_or_for_service_attachment"),
            size: :url,
            wrap_text: true,
            hyperlink: true
          },
          attorney_power_payment_stamp_duty_confirm_attachment: {
            name: column_name_translation("attorney_power_payment_stamp_duty_confirm_attachment"),
            size: :url,
            wrap_text: true,
            hyperlink: true
          },

          # attachments for divided json request_body_content_details for section 7a
          detailed_notes_parcel_site_boundary_attachment: {
            name: column_name_translation("detailed_notes_parcel_site_boundary_attachment"),
            size: :url,
            wrap_text: true,
            hyperlink: true
          },

          # attachments for section 9
          files_file_one: {
            name: column_name_translation("files_file_one"),
            size: :url,
            wrap_text: true,
            hyperlink: true
          },
          files_file_two: {
            name: column_name_translation("files_file_two"),
            size: :url,
            wrap_text: true,
            hyperlink: true
          }
        }
      end

      # Public: Serializes a collection of study notes into a flat array of hashes suitable for export.
      #
      # For each study note in the collection:
      # - If the note has no `detailed_notes` JSON, a single hash is returned (wrapped in an array for consistency).
      # - If the note includes `detailed_notes` JSON, each detailed note item is parsed and a separate hash
      #   is generated for it.
      #
      # The result is a flattened array of all serialized hashes across the collection.
      #
      # @param notes [Array<Decidim::StudyNotes::StudyNote>] The collection of study note records to serialize.
      # @return [Array<Hash>] A flat array of serialized hashes, each representing a study note or detailed note item.
      def serialize_all_with_json(notes)
        notes.flat_map do |note|
          serialize_for_json(note)
        end
      end

      # Serializes a single study note into one or more hashes for export.
      #
      # - If the study note contains no `detailed_notes` JSON data, returns a single hash
      #   wrapped in an array for consistent handling.
      # - If `detailed_notes` JSON is present, parses each entry and generates a separate
      #   hash for every detailed note item, preserving the base study note attributes.
      #
      # @param note [Decidim::StudyNotes::StudyNote] The study note object to serialize.
      # @return [Array<Hash>] An array of serialized hashes representing the study note and its detailed note items.
      def serialize_for_json(note)
        if note.detailed_notes.present?
          json_parse_detailed_notes(note)
        else
          [study_note_attrs(note, 1)]
        end
      end

      # Parses the `detailed_notes` JSON field from a study note and serializes each entry into a hash.
      #
      # Each JSON entry represents a detailed note. For every such entry, this method builds
      # a hash by merging the base study note attributes with detailed note–specific fields.
      # The resulting array includes one serialized hash per detailed note entry.
      #
      # @param note [Decidim::StudyNotes::StudyNote] The study note object containing the `detailed_notes` JSON data.
      # @return [Array<Hash>] An array of serialized hashes, one for each detailed note entry.
      def json_parse_detailed_notes(note)
        attachments = note.parcel_site_boundary.attachments

        JSON.parse(note.detailed_notes).each.with_index(1).map do |json, sequence|
          study_note_attrs(note, sequence).merge(
            detailed_notes_parcel_ids: json["parcel_ids"],
            detailed_notes_is_record_area_included: boolean_translation(json["is_record_area_included"]),
            detailed_note_functional_profile_area: (
              json["functional_profile_area_id"] if detailed_notes_functional_profile?(json)
            ),
            detailed_note_functional_profile_area_class: (
              json["functional_profile_area_classes"]&.join(", ") if detailed_notes_functional_profile?(json)
            ),
            detailed_notes_area_parameters_max_height_intensity: (
              json["max_height_intensity"] if detailed_notes_area_parameters?(json)
            ),
            detailed_notes_area_parameters_max_height_building: json["max_height_building"],
            detailed_notes_area_parameters_max_percent_area: json["max_percent_area"],
            detailed_notes_area_parameters_min_percent_bio: json["min_percent_bio"],
            detailed_notes_infill_development: (
              detailed_notes_development_boolean_translation(json["infill_development_include"]) if detailed_notes_infill_development?(json)
            ),
            detailed_notes_inner_city_development: (
              detailed_notes_development_boolean_translation(json["inner_city_development_include"]) if detailed_notes_inner_city_development?(json)
            ),
            detailed_notes_social_infrastructure_accessibility_body: (
              json["social_infrastructure_accessibility_body"] if detailed_notes_social_infrastructure?(json)
            ),
            detailed_notes_parcel_site_boundary_attachment: detailed_notes_parcel_site_boundary_url(note, attachments, sequence)
          )
        end
      end

      # Serializes a single study note into a base hash of attributes used for export.
      #
      # This method produces a hash of attributes for a study note. When the note includes
      # detailed notes (stored as JSON entries), it is invoked for each detailed note with
      # `sequence` indicating its position within that note.
      #
      # @param note [Decidim::StudyNotes::StudyNote] The study note object to serialize.
      # @param sequence [Integer] The index of the current detailed note (starts at 1).
      # @return [Hash] A hash of serialized attributes for the study note or its detailed note entry.
      def study_note_attrs(note, sequence)
        # inne załączniki for export
        file_one_url, file_two_url = attachment_urls_for_export(note)

        {
          id: note.id,
          sequential_number: note.sequential_number,
          sequence:,
          created_at: note.created_at,

          # attrs for section 4 - submitter data
          submitter_data_role: submitter_data_role_value(note),
          submitter_data_first_name: note.submitter_data_first_name,
          submitter_data_last_name: note.submitter_data_last_name,
          submitter_data_org_name: note.submitter_data_org_name,
          submitter_data_street: note.submitter_data_street,
          submitter_data_street_number: note.submitter_data_street_number,
          submitter_data_flat_number: note.submitter_data_flat_number,
          submitter_data_city: note.submitter_data_city,
          submitter_data_zip_code: note.submitter_data_zip_code,
          perpetual_owner_of_the_property: boolean_translation(note.perpetual_owner_of_the_property),

          # attrs for section 6 - attorney data
          attorney_role_all: attorney_role_all(note),
          attorney_role_delivery: attorney_role_delivery(note),
          attorney_data_first_name: note.attorney_data_first_name,
          attorney_data_last_name: note.attorney_data_last_name,

          # split json request_body_content_details for section 7a
          detailed_notes_parcel_ids: nil,
          detailed_notes_is_record_area_included: nil,
          detailed_note_functional_profile_area: nil,
          detailed_note_functional_profile_area_class: nil,
          detailed_notes_area_parameters_max_height_intensity: nil,
          detailed_notes_area_parameters_max_height_building: nil,
          detailed_notes_area_parameters_max_percent_area: nil,
          detailed_notes_area_parameters_min_percent_bio: nil,
          detailed_notes_infill_development: nil,
          detailed_notes_inner_city_development: nil,
          detailed_notes_social_infrastructure_accessibility_body: nil,

          # attrs for section 7b - request body
          request_body: note.request_body,

          # attachments for section 6 - attorney data
          attorney_power_represent_applicant_or_for_service_attachment: attorney_power_represent_applicant_or_for_service_url(note),
          attorney_power_payment_stamp_duty_confirm_attachment: attorney_power_payment_stamp_duty_confirm_url(note),

          # attachments for divided json request_body_content_details for section 7a
          detailed_notes_parcel_site_boundary_attachment: nil,

          # attachments for section 9
          files_file_one: file_one_url,
          files_file_two: file_two_url
        }
      end

      private

      def column_name_translation(column)
        I18n.t(column, scope: "decidim.study_notes.export.study_note")
      end

      def column_width(key)
        case key
        when :auto then nil
        when :body then 100
        when :url then 60
        else
          30
        end
      end

      def submitter_data_role_value(study_note)
        if study_note.submitter_data_role == Decidim::StudyNotes::StudyNote::INDIVIDUAL
          I18n.t("decidim.study_notes.export.study_note.submitter_role_person")
        else
          I18n.t("decidim.study_notes.export.study_note.submitter_role_organization")
        end
      end

      def boolean_translation(value)
        if value
          I18n.t("decidim.study_notes.export.study_note.boolean_yes")
        else
          I18n.t("decidim.study_notes.export.study_note.boolean_no")
        end
      end

      def detailed_notes_development_boolean_translation(value)
        if value == "true"
          I18n.t("decidim.study_notes.export.study_note.detailed_notes_development.boolean_yes")
        elsif value == "false"
          I18n.t("decidim.study_notes.export.study_note.detailed_notes_development.boolean_no")
        else
          ""
        end
      end

      def attorney_role_all(study_note)
        I18n.t("decidim.study_notes.export.study_note.attorney_role_all") if study_note.attorney_data_role == Decidim::StudyNotes::StudyNote::ATTORNEY
      end

      def attorney_role_delivery(study_note)
        I18n.t("decidim.study_notes.export.study_note.attorney_role_delivery") if study_note.attorney_data_role == Decidim::StudyNotes::StudyNote::ATTORNEY_FOR_SERVICE
      end

      def file_url(file, study_note)
        Rails.application.routes.url_helpers.rails_blob_url(
          file,
          host: study_note.organization.host
        )
      end

      def file_url_for(study_note, attachment_name)
        file = study_note.public_send(attachment_name)
        return "" unless file&.attached?

        file_url(file, study_note)
      end

      def attorney_power_represent_applicant_or_for_service_url(study_note)
        file_url_for(study_note, :attorney_power_represent_applicant_or_for_service)
      end

      def attorney_power_payment_stamp_duty_confirm_url(study_note)
        file_url_for(study_note, :attorney_power_payment_stamp_duty_confirm)
      end

      def detailed_notes_parcel_site_boundary_url(study_note, attachments, index)
        file = attachments[index - 1] # shift by 1
        return "" if file.blank?

        file_url(file, study_note)
      end

      # Returns an array of URLs for up to 2 files
      def attachment_urls_for_export(study_note)
        urls = study_note.files.first(2).map { |file| file_url(file, study_note) }
        urls.fill(nil, urls.size...2) # ensure exactly 2 elements
      end

      def detailed_notes_functional_profile?(json)
        json["functional_profile"].to_s == "true"
      end

      def detailed_notes_area_parameters?(json)
        json["area_parameters"].to_s == "true"
      end

      def detailed_notes_infill_development?(json)
        json["infill_development"].to_s == "true"
      end

      def detailed_notes_inner_city_development?(json)
        json["inner_city_development"].to_s == "true"
      end

      def detailed_notes_social_infrastructure?(json)
        json["detailed_notes_social_infrastructure_accessibility"].to_s == "true" &&
          json["social_infrastructure_accessibility_body"].present?
      end
    end
  end
end
