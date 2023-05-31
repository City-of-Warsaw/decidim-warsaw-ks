# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      # This command is executed when user save file as copy
      class SaveAsCopyFile < Rectify::Command
        def initialize(original_file, form, user)
          @original_file = original_file
          @form = form
          @current_user = user
        end

        # Updates the file if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          if new_file.valid?
            create_file!(new_file)
            broadcast(:ok, new_file)
          else
            @form.errors.add :file_input, new_file.errors[:file] if new_file.errors.has_key? :file
            broadcast(:invalid)
          end
        end

        private

        attr_reader :original_file, :form, :current_user

        def create_file!(new_file)
          Decidim.traceability.perform_action!(:create, new_file, current_user, visibility: "admin-only") do
            new_file.save!
          end

          # Decidim.traceability.create!(
          #   Decidim::Repository::File,
          #   current_user,
          #   copy_file_params,
          #   visibility: "admin-only"
          # )
        end

        def new_file
          @new_file ||= Decidim::Repository::File.new.tap do |f|
                          f.name = "#{form.name} - kopia"
                          f.alt = form.alt
                          f.description = form.description
                          f.copyright = form.copyright
                          f.author = form.author
                          f.folder_id = form.folder_id
                          f.creator = current_user
                          f.organization = current_user.organization

                          if form.file_input
                            f.file = form.file_input
                          else
                            raise("Poprawic dla nowej wersji Railsow") if Rails.version.to_i > 5

                            # only for Rails 5!
                            f.file.attach :io => StringIO.new(original_file.file.download),
                                                 :filename => original_file.file.filename,
                                                 :content_type => original_file.file.content_type
                          end
                        end
        end

      end
    end
  end
end
