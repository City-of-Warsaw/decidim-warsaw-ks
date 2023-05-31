# frozen_string_literal: true

module Decidim::StudyNotes
  # This class holds a Form to create legend item.
  class Admin::LegendItemForm < Decidim::Form
    mimic :legend_item

    attribute :id # used to determine if model was persisted
    attribute :name, String
    attribute :position, Integer, default: 0
    attribute :file, String
    attribute :legend_item_img_alt, String
    attribute :map_background_id, Integer

    validates :name, presence: true
    validates :position, presence: true, numericality: true
    validates :file, presence: { if: proc { |attrs| attrs[:id].blank? }} # only on create
    validates :map_background_id, presence: true

    def create_legend_item
      li = LegendItem.new
      li.component = current_component
      update_attrs(li)
      li.save
    end

    def update(li)
      update_attrs(li)
      li.save
    end

    def update_attrs(li)
      li.name = name
      li.position = position
      li.file = file if file
      li.legend_item_img_alt = legend_item_img_alt
      li.map_background_id = map_background_id
    end
  end
end
