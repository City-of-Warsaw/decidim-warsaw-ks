# frozen_string_literal: true

module Decidim::StudyNotes
  # This class holds a Form to create/edit map background.
  class Admin::MapBackgroundForm < Decidim::Form
    mimic :map_background

    attribute :position, Integer, default: 0
    attribute :name, String
    attribute :file
    attribute :file_type, String
    attribute :x_latitude, Float
    attribute :x_longitude, Float
    attribute :y_latitude, Float
    attribute :y_longitude, Float

    validates :name, presence: true
    validates :position, presence: true
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

  end
end
