# frozen_string_literal: true

module Decidim::StudyNotes
  class MapBackground < ApplicationRecord
    include Decidim::HasComponent

    enum file_type: [:raster, :vector], _suffix: true

    has_many :legend_items
    has_many :study_notes
    has_one_attached :file

    before_destroy :check_for_associated_notes_legends

    scope :sorted, -> { order("position ASC, name ASC") }

    validates :name, presence: true

    private

    def check_for_associated_notes_legends
      if study_notes.any?
        errors.add(
          :base,
          "Nie można usunąć podkładu mapowego, ponieważ została zgłoszona uwaga do studium, wykorzystująca ten pokład mapowy")
        throw :abort
      elsif legend_items.any?
        errors.add(
          :base,
          "Nie można usunąć podkładu mapowego, ponieważ została stworzona pozycja legend, wykorzystująca ten pokład mapowy")
        throw :abort
      end
    end
  end
end
