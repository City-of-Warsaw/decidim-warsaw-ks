# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      # This command is executed when user updates folder
      class UpdateFolder < Rectify::Command
        def initialize(folder, form, user)
          @folder = folder
          @form = form
          @current_user = user
        end

        # Updates the folder if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_folder!

          broadcast(:ok, folder)
        end

        private

        attr_reader :folder, :form, :current_user

        def update_folder!
          Decidim.traceability.update!(
            folder,
            current_user,
            folder_params,
            visibility: "admin-only"
          )
        end

        def folder_params
          {
            name: form.name,
            creator: current_user
          }
        end
      end
    end
  end
end
