# frozen_string_literal: true

module Decidim
  module ConsultationRequests
    module Admin
      # This command is executed when user destroys Consultation Requests
      class DestroyConsultationRequest < Decidim::Command

        def initialize(consultation_request, user)
          @consultation_request = consultation_request
          @current_user = user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        #
        # Returns nothing.
        def call
          destroy_consultation_request!
          broadcast(:ok)
        end

        private

        attr_reader :consultation_request, :current_user

        def destroy_consultation_request!
          Decidim.traceability.perform_action!(
            "delete",
            consultation_request,
            current_user
          ) do
            consultation_request.destroy!
          end
        end
      end
    end
  end
end
