# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      # This command is executed when user destroys File
      class DestroyFile < Rectify::Command

        def initialize(file, user)
          @file = file
          @current_user = user
        end

        # Destroy the file if valid.
        #
        # Broadcasts :ok if successful, :invalid if file was already destroyed.
        def call
          # return broadcast(:invalid) if file.folders.any?

          destroy_file!

          broadcast(:ok)
        end

        private

        attr_reader :file, :current_user

        def destroy_file!
          Decidim.traceability.perform_action!(
            "delete",
            file,
            current_user
          ) do
            file.destroy!
          end
        end
      end
    end
  end
end
