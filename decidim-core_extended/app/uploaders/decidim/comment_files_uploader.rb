# frozen_string_literal: true

module Decidim
  class CommentFilesUploader < Decidim::ApplicationUploader
    def validable_dimensions
      true
    end

    def extension_allowlist
      %w(
        jpg
        jpeg
        png
        pdf
        doc
        docx
      )
    end

    def content_type_allowlist
      %w(
        image/jpg
        image/jpeg
        image/png
        application/pdf
        application/msword
        application/vnd.openxmlformats-officedocument.wordprocessingml.document
      )
    end

    def max_image_height_or_width
      3840
    end

    protected

    def upload_context
      return :participant unless model.respond_to?(:context)

      model.context
    end
  end
end
