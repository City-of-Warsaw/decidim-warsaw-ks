# frozen_string_literal: true

require "valid_email2"

module Decidim
  module ConsultationMap
    module Admin
      # This class holds a Form to update Remark on map in admin panel.
      class RemarkForm < Decidim::Form
        attribute :alt, String

        mimic :remark
      end
    end
  end
end
