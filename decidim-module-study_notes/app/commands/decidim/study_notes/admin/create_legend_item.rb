# frozen_string_literal: true

module Decidim
  module StudyNotes
    module Admin
      # This command is executed when user creates study notes legend item
      class CreateLegendItem < Decidim::Command
        def initialize(form, current_component)
          @form = form
          @current_component = current_component
        end

        # Creates the legend item if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          create_legend_item

          broadcast(:ok, legend_item)
        end

        private

        attr_reader :legend_item, :form, :current_user, :current_component

        def create_legend_item
          @legend_item = Decidim.traceability.create!(
            Decidim::StudyNotes::LegendItem,
            current_user,
            legend_item_params,
            visibility: "admin-only"
          )
        end


        def legend_item_params
          { name: form.name,
            position: form.position,
            component: current_component,
            legend_item_img_alt: form.legend_item_img_alt,
            map_background_id: form.map_background_id,
          }.tap do |attrs|
            attrs[:file] = form.file if form.file.present?
          end
        end

      end
    end
  end
end
