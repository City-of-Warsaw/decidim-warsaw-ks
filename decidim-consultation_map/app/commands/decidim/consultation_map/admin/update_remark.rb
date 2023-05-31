# frozen_string_literal: true

module Decidim
  module ConsultationMap
    module Admin
      # # This command is executed when user updates Remark on map
      class UpdateRemark < Rectify::Command
        def initialize(remark, form)
          @remark = remark
          @form = form
        end

        # Updates the remark if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_remark!
          broadcast(:ok)
        end

        private

        attr_reader :remark, :form

        def update_remark!
          Decidim.traceability.update!(
            remark,
            form.current_user,
            remark_attributes,
            visibility: "admin-only"
          )
        end

        def remark_attributes
          {
            alt: form.alt
          }
        end
      end
    end
  end
end
