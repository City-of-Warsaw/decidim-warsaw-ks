# frozen_string_literal: true

module Decidim
  module ConsultationMap
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
          :comments_count,
          :signature,
          :email,
          :district,
          :age,
          :gender,
          :created_at,
          :file_url,
          :resource_url,
          :address
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
          comments_count: { name: column_name_translation("comments_count"), size: :auto },
          signature: { name: column_name_translation("signature"), size: :auto },
          email: { name: column_name_translation("email"), size: :auto },
          district: { name: column_name_translation("district"), size: :auto },
          age: { name: column_name_translation("age"), size: :auto },
          gender: { name: column_name_translation("gender"), size: :auto },
          created_at: { name: column_name_translation("created_at"), size: :auto },
          file_url: {
            name: column_name_translation("file_url"),
            size: :url,
            wrap_text: true,
            hyperlink: true
          },
          resource_url: {
            name: column_name_translation("file_url"),
            size: :url,
            wrap_text: true,
            hyperlink: true
          },
          address: { name: column_name_translation("address"), size: :auto }
        }
      end

      # Serializes a collection of remarks into an array of hashes suitable for exporting.
      # Each remark is assigned a parent sequential number (`lp`).
      # If a remark has attached files, each file gets its own row with a sub-number
      # (e.g., "1.1", "1.2"), while the parent remark information is duplicated across these rows.
      #
      # @param remarks [Array<Decidim::ConsultationMap::Remark>] The remarks to serialize
      # @return [Array<Hash>] Serialized remark data, one hash per row/file
      def serialize_all(remarks)
        rows = []
        parent_lp = 0

        remarks.each do |remark|
          parent_lp += 1
          urls = links_to_files_array(remark.files, organization: remark.organization)

          if urls.empty?
            rows << remark_attrs(remark, parent_lp)
          else
            urls.each_with_index do |url, index|
              rows << remark_attrs(remark, parent_lp, index + 1, url)
            end
          end
        end

        rows
      end

      # Returns a hash of serialized attributes for a single remark row,
      # including optional sub-numbering for attachments and an attachment URL.
      def remark_attrs(remark, parent_lp, child_lp = nil, attachment_url = nil)
        {
          lp: build_lp(parent_lp, child_lp),
          body: remark.body,
          comments_count: remark.comments_count,
          signature: remark.signature,
          email: remark.author_email,
          district: translated_attribute(remark.author_district),
          age: remark.author_age_range,
          gender: remark.author_gender,
          created_at: I18n.l(remark.created_at, format: :short),
          file_url: attachment_url,
          resource_url: resource_locator(remark).url,
          address: remark.address
        }
      end

      private

      def column_name_translation(column)
        I18n.t(column, scope: "decidim.consultation_map.export.remark")
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
