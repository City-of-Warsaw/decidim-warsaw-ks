# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      # This command is executed when user destroys gallery
      class DestroyGallery < Decidim::Command
        def initialize(gallery, user)
          @gallery = gallery
          @current_user = user
        end

        # Destroy the gallery.
        #
        # Broadcasts :ok if successful
        def call
          destroy_gallery_files!
          destroy_gallery!

          broadcast(:ok)
        end

        private

        attr_reader :gallery, :current_user

        def destroy_gallery_files!
          gallery.files.each { |file| file.destroy! }
        end

        def destroy_gallery!
          Decidim.traceability.perform_action!(
            "delete",
            gallery,
            current_user
          ) do
            gallery.destroy!
          end
        end
      end
    end
  end
end
