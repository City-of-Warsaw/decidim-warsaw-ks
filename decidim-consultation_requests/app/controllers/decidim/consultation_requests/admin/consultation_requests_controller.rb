# frozen_string_literal: true

module Decidim
  module ConsultationRequests
    module Admin
      # This controller is responsible for managing Consultation Requests in Admin Panel
      class ConsultationRequestsController < Decidim::Admin::ApplicationController
        layout "decidim/admin/consultation_requests"
        helper Decidim::ApplicationHelper

        def index
          enforce_permission_to :update, :organization
          @consultation_requests = collection.page(params[:page]).per(15)
        end

        def new
          enforce_permission_to :update, :organization
          @form = form(Decidim::ConsultationRequests::Admin::ConsultationRequestForm).instance
        end

        def create
          enforce_permission_to :update, :organization
          @form = form(Decidim::ConsultationRequests::Admin::ConsultationRequestForm).from_params(params)

          Decidim::ConsultationRequests::Admin::CreateConsultationRequest.call(@form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("consultation_requests.create.success", scope: "decidim.admin")
              redirect_to admin_consultation_requests_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("consultation_requests.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :organization
          @form = form(Decidim::ConsultationRequests::Admin::ConsultationRequestForm).from_model(consultation_request)
        end

        def update
          enforce_permission_to :update, :organization
          @form = form(Decidim::ConsultationRequests::Admin::ConsultationRequestForm).from_params(params)

          Decidim::ConsultationRequests::Admin::UpdateConsultationRequest.call(consultation_request, @form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("consultation_requests.update.success", scope: "decidim.admin")
              redirect_to admin_consultation_requests_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("consultation_requests.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def destroy
          enforce_permission_to :update, :organization

          Decidim::ConsultationRequests::Admin::DestroyConsultationRequest.call(consultation_request, current_user) do
            on(:invalid) do
              flash[:alert] = I18n.t("consultation_requests.destroy.error", scope: "decidim.admin")
              redirect_to admin_consultation_requests_path
            end

            on(:ok) do
              flash[:notice] = I18n.t("consultation_requests.destroy.success", scope: "decidim.admin")
              redirect_to admin_consultation_requests_path
            end
          end
        end

        private

        def consultation_request
          @consultation_request ||= collection.find_by(id: params[:id])
        end

        def collection
          ConsultationRequest.where(decidim_organization_id: current_organization.id).order(:created_at)
          # current_organization.consultation_requests
        end
      end
    end
  end
end
