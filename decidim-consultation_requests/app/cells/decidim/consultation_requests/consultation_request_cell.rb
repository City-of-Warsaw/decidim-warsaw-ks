# frozen_string_literal: true

module Decidim
  module ConsultationRequests
    # This cell renders the consultation request card for an instance of a Consultation Request
    class ConsultationRequestCell < Decidim::ViewModel
      include Cell::ViewModel::Partial

      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/consultation_requests/consultation_request_s"
      end
    end
  end
end
