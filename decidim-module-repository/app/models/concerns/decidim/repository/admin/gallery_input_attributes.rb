# frozen_string_literal: true

module Decidim
  module Repository
    # Extend Forms with possibilit for adding gallery from repository
    module Admin
      module GalleryInputAttributes
        extend ActiveSupport::Concern

        included do
          # gallery attr for repository
          attribute :gallery_id
          attribute :images
          # new gallery attr in the admin panel, anywhere other than in the repository:
          attribute :new_gallery_name
        end
      end
    end
  end
end
