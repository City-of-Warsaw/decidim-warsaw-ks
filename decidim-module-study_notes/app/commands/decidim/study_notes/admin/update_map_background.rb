# frozen_string_literal: true

module Decidim
  module StudyNotes
    module Admin
      # # This command is executed when user updates category for study notes map
      class UpdateMapBackground < Decidim::Command
        def initialize(map_background, form)
          @map_background = map_background
          @form = form
        end

        # Updates category if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_background

          broadcast(:ok, map_background)
        end

        private

        attr_reader :category, :form

        def update_background
          @map_background = Decidim.traceability.update!(
            map_background,
            current_user,
            map_background_params,
            visibility: "admin-only"
          )
        end

        def map_background_params
          { name: form.name,
            position: form.position,
            file_type: form.file_type,
            x_latitude: form.x_latitude,
            x_longitude: form.x_longitude,
            y_latitude: form.y_latitude,
            y_longitude: form.y_longitude }.tap do |attrs|
            attrs[:file] = form.file if form.file.present?
          end
        end
      end
    end
  end
end
