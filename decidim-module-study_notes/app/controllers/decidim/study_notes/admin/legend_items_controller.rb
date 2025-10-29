# frozen_string_literal: true

module Decidim::StudyNotes
  class Admin::LegendItemsController < Decidim::StudyNotes::Admin::ApplicationController
    helper Decidim::ApplicationHelper
    helper_method :legend_item, :map_backgrounds

    def index
      enforce_permission_to :manage, :legend_items
      @legend_items = collection.page(params[:page]).per(15)
    end

    def new
      enforce_permission_to :manage, :legend_items
      @form = Decidim::StudyNotes::Admin::LegendItemForm.new
    end

    def create
      enforce_permission_to :manage, :legend_items
      @form = form(Decidim::StudyNotes::Admin::LegendItemForm).from_params(params)

      Decidim::StudyNotes::Admin::CreateLegendItem.call(@form, current_component) do
        on(:ok) do
          redirect_to legend_items_path, notice: 'Pozycja legendy została dodana'
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("legend_item.create.error", scope: "decidim.study_notes.admin")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :manage, :legend_items
      @form = form(Decidim::StudyNotes::Admin::LegendItemForm).from_model(legend_item)
    end

    def update
      enforce_permission_to :manage, :legend_items
      @form = form(Decidim::StudyNotes::Admin::LegendItemForm).from_params(params)
      Decidim::StudyNotes::Admin::UpdateLegendItem.call(legend_item, @form) do
        on(:ok) do
          redirect_to map_backgrounds_path, notice: 'Pozycja legendy została zaktulizowana'
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("legend_item.update.error", scope: "decidim.consultation_map.admin")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :manage, :legend_item
      legend_item.destroy
      redirect_to legend_items_path, notice: 'Pozycja legendy została usunięta'
    end

    private

    def legend_item
      @legend_item ||= collection.find params[:id]
    end

    def collection
      @collection ||= Decidim::StudyNotes::LegendItem.where(component: current_component).sorted
    end

    def map_backgrounds
      @map_backgrounds ||= Decidim::StudyNotes::MapBackground.where(component: current_component).sorted.map { |map| [map.name, map.id] }
    end
  end
end
