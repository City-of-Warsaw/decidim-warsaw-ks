# frozen_string_literal: true

module Decidim
  module ConsultationMap
    module Admin
      # This command is executed when user updates Remark on map
      # Clue: update alts of remark images, if any
      class UpdateRemark < Decidim::Command
        def initialize(remark, form)
          @remark = remark
          @form = form
        end

        # Updates the each alt of file that is an image of remark if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          set_alt_on_images
          broadcast(:ok)
        end

        private

        attr_reader :remark, :form

        def set_alt_on_images
          form.image_alts.each_with_index do |alt, idx|
            next if alt.blank?

            remark.files[idx].blob.update!(metadata: { alt: })
          end
        end
      end
    end
  end
end
