# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      # This command is executed when user creates folder
      class CreateFolder < Rectify::Command
        def initialize(form, user)
          @form = form
          @current_user = user
        end

        # Creates the folder if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          create_folder!

          broadcast(:ok, folder)
        end

        private

        attr_reader :folder, :form, :current_user

        def create_folder!
          @folder = Decidim.traceability.create!(
            Decidim::Repository::Folder,
            current_user,
            folder_params,
            visibility: "admin-only"
          )
        end

        def folder_params
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
