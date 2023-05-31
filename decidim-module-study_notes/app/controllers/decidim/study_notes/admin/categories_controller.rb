# frozen_string_literal: true

module Decidim::StudyNotes
  class Admin::CategoriesController < Decidim::StudyNotes::Admin::ApplicationController
    helper Decidim::ApplicationHelper
    helper_method :category

    def index
      # enforce_permission_to :read, :map_remark
      @categories = collection.page(params[:page]).per(15)
    end

    def new
      @form = Decidim::StudyNotes::Admin::CategoryForm.new
    end

    def create
      @form = form(Decidim::StudyNotes::Admin::CategoryForm).from_params(params)
      if @form.valid?
        @form.create_category
        redirect_to categories_path, notice: 'Kategoria została dodana'
      else
        render action: :new
      end
    end

    def edit
      @form = form(Decidim::StudyNotes::Admin::CategoryForm).from_model(category)
    end

    def update
      @form = form(Decidim::StudyNotes::Admin::CategoryForm).from_params(params)
      if @form.valid?
        @form.update(category)
        redirect_to categories_path, notice: 'Kategoria została dodana'
      else
        render action: :edit
      end
    end

    def destroy
      if category.destroyable?
        category.destroy
        redirect_to categories_path, notice: 'Kategoria została usunięta'
      else
        redirect_to categories_path, error: 'Kategoria nie może zostać usunięta'
      end
    end

    private

    def permitted_params
      params[:category].permit(:name, :position)
    end

    def category
      @category ||= collection.find params[:id]
    end

    def collection
      @collection ||= Decidim::StudyNotes::Category.where(component: current_component).sorted
    end
  end
end
