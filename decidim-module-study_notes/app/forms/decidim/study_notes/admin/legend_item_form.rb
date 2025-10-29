# frozen_string_literal: true

require_dependency 'file_form_validator'

module Decidim::StudyNotes
  # This class holds a Form to create legend item.
  class Admin::LegendItemForm < Decidim::Form
    mimic :legend_item

    attribute :id # used to determine if model was persisted
    attribute :name, String
    attribute :position, Integer, default: 0
    attribute :file
    attribute :legend_item_img_alt, String
    attribute :map_background_id, Integer

    validates :name, presence: true
    validates :position, presence: true
    validates :file, presence: { if: proc { |attrs| attrs[:id].blank? }} # only on create
    validates :map_background_id, presence: true
    validates :file, file_form: {
      max_size: 60.megabytes,
      acceptable_types: %w[image/jpg image/png image/svg]
    }

  end
end
