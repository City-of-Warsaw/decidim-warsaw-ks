# frozen_string_literal: true


module Decidim
  module Repository
    module Admin
      # Custom helper that supports:
      # creating, updating & validating gallery in repository
      # creating, updating & validating new gallery during creating/updating objects in admin panel space
      module GalleriesHelper
        attr_reader :form

        def tiles_view?
          params[:view_type] && params[:view_type] == "tiles"
        end

        def add_gallery(object)
          return if form.new_gallery_name.blank? || form.images.select(&:present?).none?

          create_gallery_with_images!
          object.update_column(:gallery_id, @new_gallery.id)
        end

        def create_gallery_with_images!
          @new_gallery = Decidim.traceability.create!(
            Decidim::Repository::Gallery,
            form.current_user,
            new_gallery_params,
            visibility: "admin-only"
          )
          @new_gallery
          form.images.each do |image|
            next if image.blank?

            file = @new_gallery.files.new(
              name: image.original_filename,
              file: image,
              creator: form.current_user,
              organization: form.current_organization
            )
            @new_gallery.gallery_images.new(file: file)
          end
          @new_gallery.update!(new_gallery_params)
        end

        def new_gallery_params
          {
            name: form.new_gallery_name,
            creator: form.current_user,
            organization: form.current_organization
          }
        end
      end
    end
  end
end
