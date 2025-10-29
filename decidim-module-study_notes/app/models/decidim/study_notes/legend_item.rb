# frozen_string_literal: true

require_dependency 'file_form_validator'

module Decidim::StudyNotes
  class LegendItem < ApplicationRecord
    include Decidim::HasComponent

    has_one_attached :file
    belongs_to :map_background

    scope :sorted, -> { order("position ASC, name ASC") }

    validates :file, file_form: {
      max_size: 60.megabytes,
      acceptable_types: %w[image/jpg image/png image/svg]
    }
  end
end
