# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      # This command is executed when user creates file
      class AddFileToGallery < Rectify::Command
        def initialize(form, user)
          @form = form
          @current_user = user
        end

        # Creates the file if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          file_from_repo = Decidim::Repository::File.find_by id: form.file_id
          return broadcast(:invalid) unless file_from_repo

          if file_from_repo && form.admin_gallery_id
            gallery = Decidim::Repository::Gallery.find form.admin_gallery_id
            gallery.gallery_images.create(file: file_from_repo,
                                          name: file_from_repo.name,
                                          description: file_from_repo.description,
                                          alt: file_from_repo.alt)

            broadcast(:ok, file)
          else
            # @form.errors.add :file_input, new_test_file.errors[:file] if new_test_file.errors.has_key? :file
            broadcast(:invalid)
          end
        end

        private

        attr_reader :file, :form, :current_user

        def create_file!
          @file = Decidim.traceability.create!(
            Decidim::Repository::File,
            current_user,
            file_params,
            visibility: "admin-only"
          )
        end

        def file_params
          {
            name: form.name,
            file: form.file_input,
            alt: form.alt,
            description: form.description,
            copyright: form.copyright,
            author: form.author,
            folder_id: form.folder_id,
            creator: current_user,
            organization: current_user.organization
          }
        end
      end
    end
  end
end
