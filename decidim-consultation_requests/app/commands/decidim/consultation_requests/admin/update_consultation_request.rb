# frozen_string_literal: true

module Decidim
  module ConsultationRequests
    module Admin
      # This command is executed when user updates Consultation Requests
      class UpdateConsultationRequest < Rectify::Command

        def initialize(consultation_request, form, user)
          @form = form
          @consultation_request = consultation_request
          @current_user = user
        end

        # Updates the consultation_request if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_consultation_request!

          broadcast(:ok, consultation_request)
        end

        private

        attr_reader :consultation_request, :form, :current_user

        def update_consultation_request!
          Decidim.traceability.update!(
            consultation_request,
            current_user,
            consultation_request_params,
            visibility: "admin-only"
          )
        end

        def consultation_request_params
          {
            title: form.title,
            applicant: form.applicant,
            body: form.body,
            date_of_request: form.date_of_request,
            gallery_id: form.gallery_id,
            comments_allowed: form.comments_allowed
          }
        end
      end
    end
  end
end
