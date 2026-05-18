# frozen_string_literal: true

module Decidim
  module StudyNotes
    module Admin
      # This command is executed when user creates study notes map background
      class CreateMapBackground < Decidim::Command
        def initialize(form, current_component)
          @form = form
          @current_component = current_component
        end

        # Creates the map_background if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          create_map_background

          broadcast(:ok, map_background)
        end

        private

        attr_reader :map_background, :form, :current_user, :current_component

        def create_map_background
          @map_background = Decidim.traceability.create!(
            Decidim::StudyNotes::MapBackground,
            current_user,
            map_background_params,
            visibility: "admin-only"
          )
        end


        def map_background_params
          { name: form.name,
            component: current_component,
            position: form.position,
            file_type: form.file_type,
            x_latitude: form.x_latitude,
            x_longitude: form.x_longitude,
            y_latitude: form.y_latitude,
            y_longitude: form.y_longitude,
            visible_on_load: form.visible_on_load,
            min_zoom_level: form.min_zoom_level
          }.tap do |attrs|
            attrs[:file] = form.file if form.file.present?
          end
        end

      end
    end
  end
end
