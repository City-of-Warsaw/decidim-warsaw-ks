# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    module Admin
      # This controller is responsible for managing Article Categories in Admin Panel
      class ArticleCategoriesController < Decidim::Admin::ApplicationController
        helper Decidim::ApplicationHelper
        layout "decidim/admin/info_articles"

        def index
          enforce_permission_to :update, :organization
          @article_categories = collection.page(params[:page]).per(15)
        end

        def new
          enforce_permission_to :update, :organization
          @form = form(Decidim::AdUsersSpace::Admin::ArticleCategoryForm).instance
        end

        def create
          enforce_permission_to :update, :organization
          @form = form(Decidim::AdUsersSpace::Admin::ArticleCategoryForm).from_params(params)

          Decidim::AdUsersSpace::Admin::CreateArticleCategory.call(@form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("article_categories.create.success", scope: "decidim.admin")
              redirect_to admin_article_categories_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("article_categories.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :organization
          @form = form(Decidim::AdUsersSpace::Admin::ArticleCategoryForm).from_model(article_category)
        end

        def update
          enforce_permission_to :update, :organization
          @form = form(Decidim::AdUsersSpace::Admin::ArticleCategoryForm).from_params(params)

          Decidim::AdUsersSpace::Admin::UpdateArticleCategory.call(article_category, @form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("article_categories.update.success", scope: "decidim.admin")
              redirect_to admin_article_categories_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("article_categories.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def destroy
          enforce_permission_to :update, :organization

          Decidim::AdUsersSpace::Admin::DestroyArticleCategory.call(article_category, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("article_categories.destroy.success", scope: "decidim.admin")
              redirect_to admin_article_categories_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("article_categories.destroy.error", scope: "decidim.admin")
              redirect_to admin_article_categories_path
            end
          end
        end

        private

        def article_category
          @article_category ||= collection.find_by(id: params[:id])
        end

        def collection
          ArticleCategory.where(decidim_organization_id: current_organization.id)
          # current_organization.article_categories
        end
      end
    end
  end
end
