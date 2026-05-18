# frozen_string_literal: true

module Decidim
  module CoreExtended
    # Custom helper helps to work with serializers for export data
    module SerializerExportHelper
      include Decidim::CoreExtended::UrlHelper
      include Decidim::TranslatableAttributes
      include Decidim::ResourceHelper

      def col_index_to_column_letter(index)
        return "" if index.negative?

        letter = ""
        while index >= 0
          letter = (65 + (index % 26)).chr + letter
          index = (index / 26) - 1
        end

        letter
      end

      def headers
        columns_order.map { |column| columns_definition[column][:name] }
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

      # Builds an array of attribute values ordered according to columns_order.
      #
      # @param attrs [Hash] The hash containing object attributes.
      # @return [Array] An array of values aligned with the columns_order.
      def ordered_values(attrs)
        columns_order.map { |column| attrs[column] }
      end

      # Builds a row number (lp) for the resource, combining parent and child indices if present.
      def build_lp(parent, child)
        child ? "#{parent}.#{child}" : parent
      end

      def normalized_body(record)
        body = record.body

        body.is_a?(Hash) ? translated_attribute(body) : body
      end
    end
  end
end
