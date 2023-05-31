# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      class GalleryForm < Form
        attribute :name, String
        attribute :images, [String]
        attribute :gallery_images, Array[GalleryImageForm]
        # attribute :gallery_images

        validates :name, presence: true, length: { maximum: 60 }

        mimic :gallery

        alias organization current_organization
      end
    end
  end
end
