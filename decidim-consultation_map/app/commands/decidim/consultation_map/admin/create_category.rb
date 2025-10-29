# frozen_string_literal: true

module Decidim
  module ConsultationMap
    module Admin
      # This command is executed when user creates category
      class CreateCategory < Decidim::Command
        def initialize(form, current_component)
          @form = form
          @current_component = current_component
        end

        # Creates the category if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          create_category

          broadcast(:ok, category)
        end

        private

        attr_reader :category, :form, :current_user, :current_component

        def create_category
          @category = Decidim.traceability.create!(
            Decidim::ConsultationMap::Category,
            current_user,
            category_params,
            visibility: "admin-only"
          )
        end

        def category_params
          {
            name: form.name,
            component: current_component,
            color: form.color,
            position: form.position,
            file_id: form.file_id
          }
        end
      end
    end
  end
end
