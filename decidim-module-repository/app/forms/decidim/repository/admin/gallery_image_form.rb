# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      class GalleryImageForm < Form
        attribute :id, Integer
        # attribute :gallery_id, Integer
        # attribute :file_id, Integer
        attribute :name, String
        attribute :alt, String
        attribute :description, String
        attribute :copyright, String
        attribute :_destroy, Boolean

        mimic :gallery_image
      end
    end
  end
end
