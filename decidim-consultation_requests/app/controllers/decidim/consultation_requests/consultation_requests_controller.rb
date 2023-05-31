# frozen_string_literal: true

require_dependency "decidim/consultation_requests/application_controller"

module Decidim::ConsultationRequests
  class ConsultationRequestsController < ApplicationController
    layout "layouts/decidim/consultation_request"
    helper_method :requests_hero_section

    include Decidim::Paginable
    include Decidim::PaginateHelper
    include Decidim::SanitizeHelper
    helper Decidim::FollowableHelper
    helper Decidim::Comments::CommentsHelper
    helper Decidim::AttachmentsHelper
    helper Decidim::SanitizeHelper
    helper Decidim::Repository::ApplicationHelper

    helper_method :consultation_request, :consultation_requests, :help_section

    def index
      @consultation_requests = consultation_requests.page(params[:page]).per(15)
    end

    def show
      consultation_request
    end

    private

    def consultation_request
      @consultation_request ||= consultation_requests.find_by(id: params[:id])
    end

    def consultation_requests
      ConsultationRequest.where(decidim_organization_id: current_organization.id).latest_first
    end

    def help_section
      @help_section ||= Decidim::ContextualHelpSection.find_content(current_organization, 'consultation_requests')
    end

    def requests_hero_section
      @requests_hero_section ||= Decidim::AdminExtended::HeroSection.find_by(system_name: 'consultation_requests')
    end
  end
end
