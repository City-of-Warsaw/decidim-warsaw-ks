# frozen_string_literal: true

module Decidim
  module ConsultationMap
    module Admin
      # # This command is executed when user updates category for consultations map
      class UpdateCategory < Decidim::Command
        def initialize(category, form)
          @category = category
          @form = form
        end

        # Updates category if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?
          update_category

          broadcast(:ok, @category)
        end

        private

        attr_reader :category, :form


        def update_category
          @category = Decidim.traceability.update!(
            category,
            current_user,
            category_params,
            visibility: "admin-only"
          )
        end

        def category_params
          {
            name: form.name,
            color: form.color,
            position:form.position,
            file_id: form.file_id
          }
        end
      end
    end
  end
end
