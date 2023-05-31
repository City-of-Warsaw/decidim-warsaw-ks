# frozen_string_literal: true

module Decidim
  module Remarks
    class RemarkCell < Decidim::ViewModel
      include Cell::ViewModel::Partial
      include Decidim::Comments::CommentsHelper

      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/remarks/remark_m"
      end
    end
  end
end
