# frozen_string_literal: true

require_dependency "decidim/news/application_controller"

module Decidim::News
  class Admin::InformationsController < Decidim::Admin::ApplicationController
    helper Decidim::ApplicationHelper
    layout "decidim/admin/informations"

    def index
      enforce_permission_to :update, :organization
      @informations = collection.page(params[:page]).per(15)
    end

    def new
      enforce_permission_to :update, :organization
      @form = form(Decidim::News::Admin::InformationForm).instance
    end

    def create
      enforce_permission_to :update, :organization
      @form = form(Decidim::News::Admin::InformationForm).from_params(params)

      Decidim::News::Admin::CreateInformation.call(@form) do
        on(:ok) do
          flash[:notice] = I18n.t("informations.create.success", scope: "decidim.admin")
          redirect_to informations_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("informations.create.error", scope: "decidim.admin")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :update, :organization
      @form = form(Decidim::News::Admin::InformationForm).from_model(information)
    end

    def update
      @information = collection.find(params[:id])
      enforce_permission_to :update, :organization
      @form = form(Decidim::News::Admin::InformationForm).from_params(params)

      Decidim::News::Admin::UpdateInformation.call(information, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("informations.update.success", scope: "decidim.admin")
          redirect_to informations_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("informations.update.error", scope: "decidim.admin")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :update, :organization

      Decidim::News::Admin::DestroyInformation.call(information) do
        on(:ok) do
          flash[:notice] = I18n.t("informations.destroy.success", scope: "decidim.admin")
          redirect_to informations_path
        end
      end
    end

    private

    def information
      @information ||= collection.find_by(id: params[:id])
    end

    def collection
      Information.where(decidim_organization_id: current_organization.id)
    end
  end
end
