# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      # This command is executed when user updates gallery
      class UpdateGallery < Rectify::Command
        def initialize(gallery, form, user)
          @gallery = gallery
          @form = form
          @current_user = user
        end

        # Updates the gallery if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          # aktualizacja opisow zdjec w galerii
          @form.gallery_images.each do |gi_form|
            if gi_form._destroy
              Decidim::Repository::GalleryImage.find(gi_form.id).destroy
            else
              @gallery.gallery_images.each do |gi|
                if gi.id == gi_form.id
                  gi.name = gi_form.name
                  gi.description = gi_form.description
                  gi.alt = gi_form.alt
                  gi.save
                end
              end
            end
          end

          @form.images.each do |image|
            file = @gallery.files.new(
              name: image.original_filename,
              file: image,
              creator: current_user,
              organization: current_user.organization
            )
            @gallery.gallery_images.new(file: file)
          end

          update_gallery!

          broadcast(:ok, gallery)
        end

        private

        attr_reader :gallery, :form, :current_user

        def update_gallery!
          Decidim.traceability.update!(
            gallery,
            current_user,
            gallery_params,
            visibility: "admin-only"
          )
        end

        def gallery_params
          {
            name: form.name
          }
        end
      end
    end
  end
end
