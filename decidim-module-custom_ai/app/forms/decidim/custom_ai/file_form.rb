# frozen_string_literal: true

require_dependency "file_form_validator"

module Decidim
  module CustomAi
    # A form object to create and update File.
    class FileForm < Form
      include Decidim::HasUploadValidations
      mimic :file

      attribute :description, String
      attribute :file

      validates :file, :description, presence: true
      validates :description, length: { maximum: 500 }
      validates :file, file_form: {
        max_size: 50.megabytes,
        acceptable_types:
          %w(
            application/pdf
            application/msword
            application/vnd.openxmlformats-officedocument.wordprocessingml.document
          )
      }
    end
  end
end
