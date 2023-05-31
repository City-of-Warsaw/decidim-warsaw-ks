# frozen_string_literal: true

module Decidim::StudyNotes
  class Admin::LegendItemsController < Decidim::StudyNotes::Admin::ApplicationController
    helper Decidim::ApplicationHelper
    helper_method :legend_item, :map_backgrounds

    def index
      # enforce_permission_to :manage, :legend_item
      @legend_items = collection.page(params[:page]).per(15)
    end

    def new
      # enforce_permission_to :manage, :legend_item
      @form = Decidim::StudyNotes::Admin::LegendItemForm.new
    end

    def create
      # enforce_permission_to :manage, :legend_item
      @form = form(Decidim::StudyNotes::Admin::LegendItemForm).from_params(params)
      if @form.valid?
        @form.create_legend_item
        redirect_to legend_items_path, notice: 'Pozycja legendy została dodana'
      else
        render action: :new
      end
    end

    def edit
      # enforce_permission_to :manage, :legend_item
      @form = form(Decidim::StudyNotes::Admin::LegendItemForm).from_model(legend_item)
    end

    def update
      # enforce_permission_to :manage, :legend_item
      @form = form(Decidim::StudyNotes::Admin::LegendItemForm).from_params(params)
      if @form.valid?
        @form.update(legend_item)
        redirect_to legend_items_path, notice: 'Pozycja legendy została zaktulizowana'
      else
        render action: :edit
      end
    end

    def destroy
      # enforce_permission_to :manage, :legend_item
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
