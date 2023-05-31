# frozen_string_literal: true

require "valid_email2"

module Decidim
  module Remarks
    module Admin
      # This class holds a Form to update Remark in admin panel.
      class RemarkForm < Decidim::Form
        attribute :alt, String

        mimic :remark
      end
    end
  end
end
