# frozen_string_literal: true

module Decidim::StudyNotes
  class Category < ApplicationRecord
    include Decidim::HasComponent

    has_many :study_notes

    validates :name, presence: true
    validates :position, presence: true, numericality: true

    scope :sorted, -> { order("position ASC, name ASC") }

    # Public method that determines if object can be destroyed
    #
    # Returns: Boolean
    def destroyable?
      study_notes.none?
    end
  end
end
