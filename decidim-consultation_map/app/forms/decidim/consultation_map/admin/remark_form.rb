# frozen_string_literal: true

require "valid_email2"

module Decidim
  module ConsultationMap
    module Admin
      # This class holds a Form to update Remark on map in admin panel.
      # Clue: update alts of remark images, if any
      class RemarkForm < Decidim::Form
        attribute :image_alts, [String]

        mimic :remark
      end
    end
  end
end
