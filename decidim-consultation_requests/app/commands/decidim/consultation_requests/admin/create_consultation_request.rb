# frozen_string_literal: true

module Decidim
  module ConsultationRequests
    module Admin
      # This command is executed when user creates Consultation Request
      class CreateConsultationRequest < Rectify::Command
        def initialize(form, user)
          @form = form
          @current_user = user
        end

        # Creates the consultation_request if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          create_consultation_request!

          broadcast(:ok, consultation_request)
        end

        private

        attr_reader :consultation_request, :form, :current_user

        def create_consultation_request!
          @consultation_request = Decidim.traceability.create!(
            Decidim::ConsultationRequests::ConsultationRequest,
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
            comments_allowed: form.comments_allowed,
            gallery_id: form.gallery_id,
            organization: current_user.organization
          }
        end
      end
    end
  end
end
