# frozen_string_literal: true

require_dependency "file_form_validator"

module Decidim
  module CustomAi
    # A form object to create and update File.
    class XlsxForm < Form
      include Decidim::HasUploadValidations
      mimic :file

      attribute :file

      validates :file, presence: true
      validates :file, file_form: {
        max_size: 50.megabytes,
        acceptable_types:
          %w(
            application/vnd.ms-excel
            application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
          )
      }
    end
  end
end
