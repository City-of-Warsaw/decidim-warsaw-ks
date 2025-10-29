# frozen_string_literal: true

module Decidim
  module GeneralPlanRequests
    module Admin
      class GeneralPlanRequestsController < Decidim::GeneralPlanRequests::Admin::ApplicationController
        include Decidim::TranslatableAttributes
        include Decidim::SanitizeHelper
        include Decidim::GeneralPlanRequests::PdfAnonymisation
        include Decidim::GeneralPlanRequests::GeneralPlanRequestHelper

        helper Decidim::ApplicationHelper
        helper_method :general_plan_request,
                      :file_present?,
                      :col_index_to_column_letter,
                      :collection,
                      :display_other_files

        def index
          enforce_permission_to :manage, :general_plan_requests

          @gpr = collection.page(params[:page]).per(25)
        end

        def show
          enforce_permission_to :manage, :general_plan_requests

          pdf_name = general_plan_request.pdf_name

          if params[:anonimized] == "true"
            anonymize_general_plan_request(general_plan_request)
            pdf_name = general_plan_request.anonymized_pdf_name
          end

          respond_to do |format|
            format.html
            format.pdf do
              render pdf: pdf_name,
                     disposition: 'attachment',
                     template: general_plan_request.pdf_template,
                     javascript_delay: 2000,
                     locals: { general_plan_request: general_plan_request }
            end
          end
        end

        # controller action for exporting requests data to xls file
        def export
          enforce_permission_to :manage, :general_plan_requests

          @xml_serializer = Decidim::GeneralPlanRequests::GeneralPlanRequestSerializer.new

          @gpr = collection

          # Logging action needs to have resource - for show/list its first/any item
          create_log(collection.first, :export_general_plan_requests) if collection.any?

          respond_to do |format|
            format.xlsx { render 'decidim/general_plan_requests/admin/general_plan_requests/export' }
          end
        end

        # register by admin - only for test purpose
        def register_to_signum
          enforce_permission_to :register_to_signum, :general_plan_request, general_plan_request: general_plan_request

          Decidim::GeneralPlanRequests::Admin::RegisterToSignum.call(current_component, current_user, general_plan_request) do
            on(:registered_already) do
              flash[:alert] = 'Ten wniosek już jest zarejestrowany w Signum.'
            end

            on(:ok) do
              flash[:notice] = 'Zarejestrowano wniosek w Signum'
            end
          end

          redirect_to general_plan_request_path(general_plan_request)
        end

        private

        def collection
          @collection ||= Decidim::GeneralPlanRequests::GeneralPlanRequest.where(component: current_component).order(created_at: :desc)
        end

        def general_plan_request
          @general_plan_request ||= collection.find params[:id]
        end

        def create_log(resource, log_type)
          Decidim::ActionLogger.log(
            log_type,
            current_user,
            resource,
            nil,
            { visibility: 'admin-only' }
          )
        end
      end
    end
  end
end
