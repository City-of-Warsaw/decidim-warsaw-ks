# frozen_string_literal: true

module Decidim
  module ConsultationMap
    class RemarkCell < Decidim::ViewModel
      include Cell::ViewModel::Partial
      include Decidim::Comments::CommentsHelper

      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/consultation_map/remark_m"
      end
    end
  end
end
