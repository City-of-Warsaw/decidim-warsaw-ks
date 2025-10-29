# frozen_string_literal: true

require_dependency 'decidim/general_plan_requests/application_controller'

module Decidim
  module GeneralPlanRequests
    class GeneralPlanRequestsController < Decidim::GeneralPlanRequests::ApplicationController
      include Decidim::FormFactory
      include Decidim::GeneralPlanRequests::GeneralPlanRequestHelper

      helper_method :general_plan_request,
                    :file_present?

      def index
        @form = form(Decidim::GeneralPlanRequests::GeneralPlanRequestForm).instance
      end

      def show
        respond_to do |format|
          format.html
          format.pdf do
            render pdf: general_plan_request.pdf_name,
                   disposition: 'attachment',
                   template: general_plan_request.pdf_template,
                   formats: [:pdf]
          end
        end
      end

      def create
        @form = form(Decidim::GeneralPlanRequests::GeneralPlanRequestForm).from_params(params)

        if params[:subaction] == 'preview_pdf'
          # Handle PDF preview without saving the record
          render pdf: 'podgląd wniosku',
                 template: 'decidim/general_plan_requests/shared/show',
                 disposition: 'inline',
                 formats: [:pdf],
                 locals: { general_plan_request: @form }
        else
          # Handle create request
          Decidim::GeneralPlanRequests::CreateGeneralPlanRequest.call(@form) do

            on(:ok) do |general_plan_request|
              redirect_to general_plan_request_path(general_plan_request.uuid, anchor: 'subcontent')
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t('general_plan_requests.create.invalid', scope: 'decidim.general_plan_requests')
              render :index
            end
          end
        end
      end

      private

      def general_plan_request
        @general_plan_request ||= Decidim::GeneralPlanRequests::GeneralPlanRequest.where(component: current_component)
                                                                                  .find_by(uuid: params[:uuid])
      end
    end
  end
end
