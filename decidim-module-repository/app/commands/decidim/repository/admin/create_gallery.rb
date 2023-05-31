# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      # This command is executed when user creates gallery
      class CreateGallery < Rectify::Command
        def initialize(form, user)
          @form = form
          @current_user = user
        end

        # Creates the gallery if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          create_gallery!

          broadcast(:ok, gallery)
        end

        private

        attr_reader :gallery, :form, :current_user

        def create_gallery!
          @gallery = Decidim.traceability.create!(
            Decidim::Repository::Gallery,
            current_user,
            gallery_params,
            visibility: "admin-only"
          )
        end

        def gallery_params
          {
            name: form.name,
            creator: current_user,
            organization: current_user.organization
          }
        end
      end
    end
  end
end
