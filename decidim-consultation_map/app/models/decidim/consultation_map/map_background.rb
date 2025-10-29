# frozen_string_literal: true

module Decidim::ConsultationMap
  class MapBackground < ApplicationRecord
    include Decidim::HasComponent

    has_one_attached :file
    scope :sorted, -> { order("position ASC, name ASC") }

    enum file_type: [:raster, :vector], _suffix: true

    validates :name, presence: true
  end
end
