# frozen_string_literal: true

module Decidim::Repository
  class Gallery < ApplicationRecord

    belongs_to :creator,
               foreign_key: 'creator_id',
               class_name: 'Decidim::User'
    belongs_to :organization,
               foreign_key: 'decidim_organization_id',
               class_name: 'Decidim::Organization'
    has_many :gallery_images, -> { sorted }, dependent: :destroy
    has_many :files, through: :gallery_images

    validates :name, presence: true

    scope :alphabetical, -> { order(name: :asc) }
    scope :latest_first, -> { order(created_at: :desc) }

    def images
      files.images
    end
  end
end
