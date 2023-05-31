# frozen_string_literal: true

module Decidim::StudyNotes
  # This class holds a Form to create map background.
  class Admin::MapBackgroundForm < Decidim::Form

    mimic :map_background

    attribute :id # used to determine if model was persisted
    attribute :position, Integer, default: 0
    attribute :name, String
    attribute :file, String
    attribute :file_type, String
    attribute :x_latitude, Float
    attribute :x_longitude, Float
    attribute :y_latitude, Float
    attribute :y_longitude, Float

    validates :name, presence: true
    validates :position, presence: true, numericality: true
    validates :file_type, presence: true
    validates :file, presence: { if: proc { |attrs| attrs[:id].blank? }} # only on create
    validate :lat_and_long_for_raster_file

    def lat_and_long_for_raster_file
      if file_type.present? && file_type == 'raster' &&
        x_latitude.blank? && x_longitude.blank? &&
        y_latitude.blank? && y_longitude.blank?
        errors.add(:x_latitude, 'Nie może być puste dla pliku rastrowego')
        errors.add(:x_longitude, 'Nie może być puste dla pliku rastrowego')
        errors.add(:y_latitude, 'Nie może być puste dla pliku rastrowego')
        errors.add(:y_longitude, 'Nie może być puste dla pliku rastrowego')
      end
    end

    def create_map_background
      bg = MapBackground.new
      bg.component = current_component
      update_attrs(bg)
      bg.save
    end

    def update(bg)
      update_attrs(bg)
      bg.save
    end

    def update_attrs(bg)
      bg.name = name
      bg.file = file if file
      bg.position = position
      bg.file_type = file_type
      bg.x_latitude = x_latitude
      bg.x_longitude = x_longitude
      bg.y_latitude = y_latitude
      bg.y_longitude = y_longitude
    end
  end
end
