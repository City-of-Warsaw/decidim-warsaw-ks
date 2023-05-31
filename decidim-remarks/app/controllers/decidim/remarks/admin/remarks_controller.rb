# frozen_string_literal: true

module Decidim::Remarks::Admin
  class RemarksController < Decidim::Remarks::Admin::ApplicationController
    helper Decidim::ApplicationHelper
    helper_method :remark

    def index
      enforce_permission_to :read, :remark
      @remarks = collection.page(params[:page]).per(15)
    end

    # controller action for exporting remarks data to xls file
    def export
      enforce_permission_to :read, :remark

      @remarks = collection
      # TODO: create_log(current_user, 'remarks_export')
      respond_to do |format|
        format.xlsx
      end
    end

    def edit
      enforce_permission_to :update, :remark
      @form = form(Decidim::Remarks::Admin::RemarkForm).from_model(remark)
    end

    def update
      enforce_permission_to :update, :remark
      @form = form(Decidim::Remarks::Admin::RemarkForm).from_params(params)

      Decidim::Remarks::Admin::UpdateRemark.call(remark, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("remarks.update.success", scope: "decidim.remarks.admin")
          redirect_to remarks_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("remarks.update.error", scope: "decidim.remarks.admin")
          render :edit
        end
      end
    end

    private

    def collection
      @collection ||= Decidim::Remarks::Remark.where(component: current_component).order(created_at: :desc)
    end

    def remark
      @remark ||= collection.find(params[:id]) if params[:id]
    end
  end
end
