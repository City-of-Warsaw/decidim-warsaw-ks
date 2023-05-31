# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      # This command is executed when user updates file
      class UpdateFile < Rectify::Command
        def initialize(file, form, user)
          @file = file
          @form = form
          @current_user = user
        end

        # Updates the file if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          test_file_update

          if test_file_update.valid?
            update_file!
            broadcast(:ok, @file)
          else
            @form.errors.add :file_input, @file.errors[:file] if @file.errors.has_key? :file
            broadcast(:invalid)
          end
        end

        private

        attr_reader :file, :form, :current_user

        def update_file!
          Decidim.traceability.update!(
            @file,
            current_user,
            file_params,
            visibility: "admin-only"
          )
        end

        def file_params
          {}.tap do |h|
            h[:name] = form.name
            h[:alt] = form.alt
            h[:description] = form.description
            h[:copyright] = form.copyright
            h[:author] = form.author
            h[:permission] = form.permission
            h[:folder_id] = form.folder_id
            h[:file] = form.file_input if form.file_input
            h[:audio_description] = form.audio_description_input if form.audio_description_input
            h[:subtitles] = form.subtitles_input if form.subtitles_input
            h[:subtitles_for_readers] = form.subtitles_for_readers_input if form.subtitles_for_readers_input
          end
        end

        def test_file_update
          @file.name = @form.name
          @file.alt = @form.alt
          @file.description = @form.description
          @file.copyright = @form.copyright
          @file.author = @form.author
          @file.permission = @form.permission
          @file.file = @form.file_input if @form.file_input
          @file.audio_description = @form.audio_description_input if @form.audio_description_input
          @file.subtitles = @form.subtitles_input if @form.subtitles_input
          @file.subtitles_for_readers = @form.subtitles_for_readers_input if @form.subtitles_for_readers_input
          @file
        end
      end
    end
  end
end
