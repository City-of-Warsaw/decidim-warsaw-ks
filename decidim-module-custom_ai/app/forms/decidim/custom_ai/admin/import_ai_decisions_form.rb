# frozen_string_literal: true

require_dependency "file_form_validator"

module Decidim
  module CustomAi
    module Admin
      # This class holds a Form to update the questionnaire answers from Decidim's admin with 1 collective action importing excel file
      class ImportAiDecisionsForm < Decidim::Form
        attribute :xlsx_file

        validates :xlsx_file, presence: true
        validates :xlsx_file, file_form: {
          max_size: 50.megabytes,
          acceptable_types: %w(application/vnd.openxmlformats-officedocument.spreadsheetml.sheet)
        }
      end
    end
  end
end
