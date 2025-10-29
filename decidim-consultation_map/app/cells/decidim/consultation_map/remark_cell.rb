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
        if options[:size] == :l
          "decidim/consultation_map/remark_l"
        else
          "decidim/consultation_map/remark_s"
        end
      end

      def mounted_engine
        "decidim_consultation_map"
      end
    end
  end
end
