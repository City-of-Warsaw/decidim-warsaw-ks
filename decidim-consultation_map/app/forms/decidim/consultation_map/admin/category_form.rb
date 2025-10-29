# frozen_string_literal: true

module Decidim::ConsultationMap
  # This class holds a Form to create / edit category.
  class Admin::CategoryForm < Decidim::Form

    mimic :category

    attribute :name, String
    attribute :position, Integer, default: 0
    attribute :file_id, Integer
    attribute :color, String

    validates :name, presence: true
    validates :position, presence: true
    validates :color, presence: true
  end
end
