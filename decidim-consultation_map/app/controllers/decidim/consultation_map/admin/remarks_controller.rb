# frozen_string_literal: true

module Decidim::ConsultationMap::Admin
  class RemarksController < Decidim::ConsultationMap::Admin::ApplicationController
    helper Decidim::ApplicationHelper
    helper_method :remark

    def index
      enforce_permission_to :read, :map_remark
      @remarks = collection.page(params[:page]).per(15)
    end

    # controller action for exporting remarks data to xls file
    def export
      enforce_permission_to :read, :map_remark

      @remarks = collection
      # TODO: create_log(current_user, 'remarks_export')
      respond_to do |format|
        format.xlsx
      end
    end

    def edit
      enforce_permission_to :update, :map_remark
      @form = form(Decidim::ConsultationMap::Admin::RemarkForm).from_model(remark)
    end

    def update
      enforce_permission_to :update, :map_remark
      @form = form(Decidim::ConsultationMap::Admin::RemarkForm).from_params(params)

      Decidim::ConsultationMap::Admin::UpdateRemark.call(remark, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("remarks.update.success", scope: "decidim.consultation_map.admin")
          redirect_to remarks_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("remarks.update.error", scope: "decidim.consultation_map.admin")
          render :edit
        end
      end
    end

    private

    def collection
      @collection ||= Decidim::ConsultationMap::Remark.where(component: current_component).order(created_at: :desc)
    end

    def remark
      @remark ||= collection.find(params[:id]) if params[:id]
    end

  # def current_component
  #   remark.try(:component)
  # end
  end
end
