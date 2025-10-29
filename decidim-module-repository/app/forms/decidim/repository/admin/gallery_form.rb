# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      class GalleryForm < Form
        include Decidim::Repository::Admin::GalleryInputAttributes
        include Decidim::Repository::Admin::GalleriesValidations

        attribute :name, String
        attribute :gallery_images, [GalleryImageForm]

        validates :name, presence: true, length: { maximum: 60 }

        mimic :gallery

        alias organization current_organization

        # Due to different attributes names:
        # Override the name_if_images validation, for this particular form, to do nothing.
        def name_if_images; end
      end
    end
  end
end
