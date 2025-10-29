# frozen_string_literal: true

module Decidim
  module StudyNotes
    module Admin
      # # This command is executed when user updates legend item for study notes map
      class UpdateLegendItem < Decidim::Command
        def initialize(legend_item, form)
          @legend_item = legend_item
          @form = form
        end

        # Updates legend item if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_legend_item

          broadcast(:ok, legend_item)
        end

        private

        attr_reader :legend_item, :form

        def update_legend_item
          @legend_item = Decidim.traceability.update!(
            legend_item,
            current_user,
            legend_item_params,
            visibility: "admin-only"
          )
        end

          def legend_item_params
            { name: form.name,
              component: current_component,
              position: form.position,
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
