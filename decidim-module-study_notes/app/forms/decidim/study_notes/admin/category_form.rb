# frozen_string_literal: true

module Decidim::StudyNotes
  # This class holds a Form to create category.
  class Admin::CategoryForm < Decidim::Form

    mimic :category

    attribute :id # used to determine if model was persisted
    attribute :name, String
    attribute :position, Integer, default: 0

    validates :name, presence: true
    validates :position, presence: true, numericality: true

    def create_category
      category = Category.new
      category.component = current_component
      update_attrs(category)
      category.save
    end

    def update(category)
      update_attrs(category)
      category.save
    end

    def update_attrs(category)
      category.name = name
      category.position = position
    end
  end
end
