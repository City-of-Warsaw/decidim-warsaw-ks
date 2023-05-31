# frozen_string_literal: true

module Decidim::Repository
  class GalleryImage < ApplicationRecord
    belongs_to :file
    belongs_to :gallery, counter_cache: true

    scope :sorted, -> { order(position: :asc) }

    before_create :update_last_position

    def update_last_position
      self.position = gallery.files.count
    end
  end
end
