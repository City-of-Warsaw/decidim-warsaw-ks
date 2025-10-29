# frozen_string_literal: true

require_dependency "decidim/consultation_requests/application_controller"

module Decidim::ConsultationRequests
  class ConsultationRequestsController < ApplicationController
    layout "layouts/decidim/hero_section_banner"

    include Decidim::AdminExtended::HeroSectionHelper
    include Decidim::Paginable
    include Decidim::PaginateHelper
    include Decidim::SanitizeHelper
    
    helper Decidim::Comments::CommentsHelper
    helper Decidim::AttachmentsHelper
    helper Decidim::SanitizeHelper
    helper Decidim::Repository::ApplicationHelper

    helper_method :consultation_request, :consultation_requests, :hero_section_public, :info_or_request_title,
                  :banner_partial_name, :pages_or_info_articles?

    def index
      @consultation_requests = paginate(consultation_requests)
    end

    def show
      raise ActionController::RoutingError, "Not Found" unless consultation_request

      consultation_request
    end

    private

    def consultation_request
      @consultation_request ||= consultation_requests.find_by(id: params[:id])
    end

    def consultation_requests
      @consultation_requests ||= Decidim::ConsultationRequests::ConsultationRequest.where(decidim_organization_id: current_organization.id).latest_first
    end
  end
end
