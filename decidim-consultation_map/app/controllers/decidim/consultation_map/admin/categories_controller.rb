# frozen_string_literal: true

module Decidim::ConsultationMap
  class Admin::CategoriesController < Decidim::ConsultationMap::Admin::ApplicationController
    helper Decidim::ApplicationHelper
    helper_method :category

    before_action :set_categories_breadcrumb_item

    def index
      enforce_permission_to :manage, :map_remark_category
      @categories = collection.page(params[:page]).per(15)
    end

    def new
      enforce_permission_to :manage, :map_remark_category
      @form = Decidim::ConsultationMap::Admin::CategoryForm.new
    end

    def show
      enforce_permission_to :manage, :map_remark_category
    end

    def create
      enforce_permission_to :manage, :map_remark_category
      @form = form(Decidim::ConsultationMap::Admin::CategoryForm).from_params(params)

      Decidim::ConsultationMap::Admin::CreateCategory.call(@form, current_component) do
        on(:ok) do |category|
          flash[:notice] = I18n.t("category.create.success", scope: "decidim.consultation_map.admin")
          redirect_to category_path(category)
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("category.create.error", scope: "decidim.consultation_map.admin")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :manage, :map_remark_category

      @form = form(Decidim::ConsultationMap::Admin::CategoryForm).from_model(category)
    end

    def update
      enforce_permission_to :manage, :map_remark_category

      @form = form(Decidim::ConsultationMap::Admin::CategoryForm).from_params(params)

      Decidim::ConsultationMap::Admin::UpdateCategory.call(category, @form) do
        on(:ok) do |category|
          flash[:notice] = I18n.t("category.update.success", scope: "decidim.consultation_map.admin")
          redirect_to category_path(category)
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("category.update.error", scope: "decidim.consultation_map.admin")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :manage, :map_remark_category

      if category.destroy
        redirect_to categories_path, notice: 'Kategoria została usunięta'
      else
        redirect_to categories_path, error: 'Kategoria nie może zostać usunięta'
      end
    end

    private

    def category
      @category ||= collection.find params[:id]
    end

    def collection
      @collection ||= Decidim::ConsultationMap::Category.where(component: current_component).sorted
    end

    def set_categories_breadcrumb_item
      controller_breadcrumb_items << {
        label: I18n.t("title", scope: "decidim.consultation_map.admin.categories.index"),
        url: categories_path,
        active: true
      }
    end
  end
end
