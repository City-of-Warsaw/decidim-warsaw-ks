# frozen_string_literal: true
#
require_dependency "decidim/study_notes/application_controller"

module Decidim::StudyNotes
  class Admin::MapBackgroundsController < Decidim::StudyNotes::Admin::ApplicationController
    helper Decidim::ApplicationHelper
    helper_method :map_background

    def index
      enforce_permission_to :manage, :map_backgrounds
      @map_backgrounds = collection.page(params[:page]).per(15)
    end

    def new
      enforce_permission_to :manage, :map_backgrounds
      @form = Decidim::StudyNotes::Admin::MapBackgroundForm.new
    end

    def create
      enforce_permission_to :manage, :map_backgrounds

      @form = form(Decidim::StudyNotes::Admin::MapBackgroundForm).from_params(params)
      Decidim::StudyNotes::Admin::CreateMapBackground.call(@form, current_component) do
        on(:ok) do
          flash[:notice] = I18n.t("map_background.create.success", scope: "decidim.consultation_map.admin")
          redirect_to map_backgrounds_path, notice: 'Podkład mapowy został dodany'
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("map_background.create.error", scope: "decidim.consultation_map.admin")
          render :new
        end
      end
    end

    def edit
      # enforce_permission_to :manage, :map_background
      @form = form(Decidim::StudyNotes::Admin::MapBackgroundForm).from_model(map_background)
    end

    def update
      enforce_permission_to :manage, :map_backgrounds


      @form = form(Decidim::StudyNotes::Admin::MapBackgroundForm).from_params(params)
      Decidim::StudyNotes::Admin::UpdateMapBackground.call(map_background, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("map_background.update.success", scope: "decidim.consultation_map.admin")
          redirect_to map_backgrounds_path, notice: 'Podkład mapowy został zaktualizowany'
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("map_background.update.error", scope: "decidim.consultation_map.admin")
          render :edit
        end
      end
    end

    def destroy
      # enforce_permission_to :manage, :map_background
      map_background.destroy
      if map_background.destroyed?
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
      @collection ||= Decidim::StudyNotes::MapBackground.where(component: current_component).sorted
    end
  end
end
