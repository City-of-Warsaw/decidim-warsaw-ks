# frozen_string_literal: true

module Decidim
  module Remarks
    class RemarksSerializer < Decidim::Exporters::Serializer
      include Decidim::CoreExtended::SerializerExportHelper

      def initialize(resource = nil)
        super(resource)
      end

      # Public: Get the order of columns for serializing a remark.
      # Returns an Array of symbols representing the column order.
      def columns_order
        @columns_order ||= [
          :lp,
          :body,
          :signature,
          :email,
          :district,
          :age,
          :gender,
          :url,
          :created_at
        ]
      end

      def columns_definition
        @columns_definition ||= {
          lp: {
            name: column_name_translation("lp"),
            size: :auto,
            alignment: :right
          },
          body: {
            name: column_name_translation("body"),
            size: :body,
            wrap_text: true
          },
          signature: { name: column_name_translation("signature"), size: :auto },
          email: { name: column_name_translation("email"), size: :auto },
          district: { name: column_name_translation("district"), size: :auto },
          age: { name: column_name_translation("age"), size: :auto },
          gender: { name: column_name_translation("gender"), size: :auto },
          url: {
            name: column_name_translation("url"),
            size: :url,
            wrap_text: true,
            hyperlink: true
          },
          created_at: { name: column_name_translation("created_at"), size: :auto }
        }
      end

      # Serializes remarks and their visible comments into flat rows structure.
      # Each remark without comments is serialized as a single group.
      # If a remark has visible comments, only its comments are serialized.
      # Handles attachment expansion and sequential numbering (lp).
      def serialize_all(remarks)
        rows = []
        parent_lp = 0

        remarks.each do |remark|
          unless remark.hidden?
            parent_lp += 1
            rows.concat(serialize_record(remark, parent_lp))
          end

          remark.comments.not_hidden.find_each do |comment|
            parent_lp += 1
            rows.concat(serialize_record(comment, parent_lp))
          end
        end

        rows
      end

      # Serializes a single record (remark or comment) into one or more rows.
      # If the record has attachments, each attachment is expanded into a separate row
      # with sub-numbering (child lp) and attachment URL.
      # Returns an array of row attribute hashes.
      def serialize_record(record, parent_lp)
        urls = links_to_files_array(record.files, organization: record.organization)

        if urls.empty?
          [row_attrs(record, parent_lp)]
        else
          urls.map.with_index(1) do |url, index|
            row_attrs(record, parent_lp, index, url)
          end
        end
      end

      # Builds a single export row for a remark or comment.
      # Normalizes content differences between record types, applies lp numbering,
      # and enriches the row with author metadata, optional attachment URL,
      # and localized creation timestamp.
      def row_attrs(record, parent_lp, child_lp = nil, attachment_url = nil)
        {
          lp: build_lp(parent_lp, child_lp),
          body: normalized_body(record),
          signature: record.signature,
          email: record.author_email,
          district: translated_attribute(record.author_district),
          age: record.author_age_range,
          gender: record.author_gender,
          url: attachment_url,
          created_at: I18n.l(record.created_at, format: :short)
        }
      end

      private

      def column_name_translation(column)
        I18n.t(column, scope: "decidim.remarks.export.remark")
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
    end
  end
end
