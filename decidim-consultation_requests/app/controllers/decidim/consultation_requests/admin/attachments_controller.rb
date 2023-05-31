# frozen_string_literal: true

module Decidim
  module ConsultationRequests
    module Admin
      # Controller that allows managing all the attachments for a participatory
      # process.
      #
      class AttachmentsController < Admin::ApplicationController
        include Decidim::Admin::Concerns::HasAttachments

        def after_destroy_path
          admin_consultation_request_attachments_path(attached_to)
        end

        def attached_to
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
