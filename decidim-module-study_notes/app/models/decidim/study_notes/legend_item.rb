# frozen_string_literal: true

module Decidim::StudyNotes
  class LegendItem < ApplicationRecord
    include Decidim::HasComponent

    has_one_attached :file
    belongs_to :map_background

    scope :sorted, -> { order("position ASC, name ASC") }

    validate :acceptable_file

    def acceptable_file
      return unless file.attached?

      unless file.byte_size <= 50.megabyte
        errors.add(:file, "Maksymalny rozmiar pliku to 50MB")
      end

      acceptable_types = ["image/jpg", "image/png", "image/svg"]
      unless acceptable_types.include?(file.content_type)
        errors.add(:file, "Dozwolne rozszerzenia plików: jpg png svg")
      end
    end
  end
end
