# frozen_string_literal: true

module Decidim
  module ConsultationMap
    class CategoryIconUploader < ImageUploader
      def content_type_allowlist
        %w(image/jpeg image/png image/svg+xml)
      end

      def extension_allowlist
        %w(jpeg jpg png svg)
      end

      # overwritten for no processing svg files
      def enable_processing
        false
      end
      # overwritten for no processing svg files
      def validable_dimensions
        false
      end
    end
  end
end