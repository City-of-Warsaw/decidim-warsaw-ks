# frozen_string_literal: true
#
module Decidim::ConsultationMap
  class Admin::MapBackgroundsController < Decidim::ConsultationMap::Admin::ApplicationController

    helper Decidim::ApplicationHelper
    helper Decidim::PaginateHelper
    helper_method :map_background

    before_action :set_map_backgrounds_breadcrumb_item

    def index
      enforce_permission_to :manage, :map_remark_map_background
      @map_backgrounds = collection.page(params[:page]).per(15)
    end

    def new
      enforce_permission_to :manage, :map_remark_map_background
      @form = Decidim::ConsultationMap::Admin::MapBackgroundForm.new
    end

    def create
      enforce_permission_to :manage, :map_remark_map_background
      @form = form(Decidim::ConsultationMap::Admin::MapBackgroundForm).from_params(params)

      Decidim::ConsultationMap::Admin::CreateMapBackground.call(@form, current_component) do
        on(:ok) do
          flash[:notice] = I18n.t("map_background.create.success", scope: "decidim.consultation_map.admin")
          redirect_to map_backgrounds_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("map_background.create.error", scope: "decidim.consultation_map.admin")
          render :new
        end
      end

    end

    def edit
      enforce_permission_to :manage, :map_remark_map_background

      @form = form(Decidim::ConsultationMap::Admin::MapBackgroundForm).from_model(map_background)
    end

    def update
      enforce_permission_to :manage, :map_remark_map_background

      @form = form(Decidim::ConsultationMap::Admin::MapBackgroundForm).from_params(params)
      Decidim::ConsultationMap::Admin::UpdateMapBackground.call(map_background, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("map_background.update.success", scope: "decidim.consultation_map.admin")
          redirect_to map_backgrounds_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("map_background.update.error", scope: "decidim.consultation_map.admin")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :manage, :map_remark_map_background

      if map_background.destroy
        redirect_to map_backgrounds_path, notice: 'Podkład mapowy został usunięty'
      else
        redirect_to map_backgrounds_path, alert: 'Nie udało się usunąć podkładu mapowego'
      end
    end

    private

    def map_background
      @map_background ||= collection.find params[:id]
    end

    def collection
      @collection ||= Decidim::ConsultationMap::MapBackground.where(component: current_component).sorted
    end

    def set_map_backgrounds_breadcrumb_item
      controller_breadcrumb_items << {
        label: I18n.t("title", scope: "decidim.consultation_map.admin.map_backgrounds.index"),
        url: map_backgrounds_path,
        active: true
      }
    end
  end
end
