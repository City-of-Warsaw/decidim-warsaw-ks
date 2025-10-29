# frozen_string_literal: true

module Decidim
  module CustomProposals
    class CustomProposalCell < Decidim::ViewModel
      include Cell::ViewModel::Partial

      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/custom_proposals/custom_proposal_s"
      end
    end
  end
end
