# frozen_string_literal: true

module Decidim
  module ConsultationRequests
    # This cell renders the card for an instance of a Information
    # the default size is the Medium Card (:m)
    class ConsultationRequestCell < Decidim::ViewModel
      include Cell::ViewModel::Partial

      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/consultation_requests/consultation_request_m"
      end
    end
  end
end
