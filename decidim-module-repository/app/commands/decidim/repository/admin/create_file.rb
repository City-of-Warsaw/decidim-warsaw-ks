# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      # This command is executed when user creates file
      class CreateFile < Rectify::Command
        def initialize(form, user)
          @form = form
          @current_user = user
        end

        # Creates the file if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid, form) if form.invalid?

          new_test_file = Decidim::Repository::File.new(file_params)

          if new_test_file.valid?
            create_file!

            if form.admin_gallery_id
              gallery = Decidim::Repository::Gallery.find form.admin_gallery_id
              gallery.gallery_images.create(file: @file)
            end

            broadcast(:ok, file)
          else
            @form.errors.add :file_input, new_test_file.errors[:file] if new_test_file.errors.has_key? :file
            broadcast(:invalid, @form)
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
            audio_description: form.audio_description_input,
            subtitles: form.subtitles_input,
            subtitles_for_readers: form.subtitles_for_readers_input,
            alt: form.alt,
            description: form.description,
            copyright: form.copyright,
            author: form.author,
            permission: form.permission.presence || default_permission,
            folder_id: form.folder_id,
            creator: current_user,
            organization: current_user.organization
          }
        end

        # 2 - editable by all
        def default_permission
          :editable
        end
      end
    end
  end
end
