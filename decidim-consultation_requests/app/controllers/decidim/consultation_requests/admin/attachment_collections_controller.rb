# frozen_string_literal: true

module Decidim
  module ConsultationRequests
    module Admin
      # Controller that allows managing all the attachment collections for a Consultation Request.
      #
      class AttachmentCollectionsController < Admin::ApplicationController
        include Decidim::Admin::Concerns::HasAttachmentCollections

        def after_destroy_path
          admin_consultation_request_attachment_collections_path(consultation_request)
        end

        def collection_for
          consultation_request
        end

        def consultation_request
          @consultation_request ||= consultation_requests.find(params[:admin_consultation_request_id])
        end

        def consultation_requests
          ConsultationRequest.where(decidim_organization_id: current_organization.id)
        end
      end
    end
  end
end
