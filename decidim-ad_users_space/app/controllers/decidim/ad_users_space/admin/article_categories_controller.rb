# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    module Admin
      # This controller is responsible for managing Article Categories in Admin Panel
      class ArticleCategoriesController < Decidim::Admin::ApplicationController
        include Decidim::Admin::Concerns::HasTabbedMenu
        include Decidim::Admin::Officializations::Filterable

        before_action :set_article_categories_breadcrumb_item

        helper Decidim::ApplicationHelper

        def index
          enforce_permission_to :update, :organization
          @article_categories = filtered_collection
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

        def tab_menu_name = :admin_info_articles_menu

        def article_category
          @article_category ||= collection.find_by(id: params[:id])
        end

        def collection
          @collection ||= Decidim::AdUsersSpace::ArticleCategory.where(decidim_organization_id: current_organization.id)
                                                                .sorted_by_weight
        end

        def set_article_categories_breadcrumb_item
          controller_breadcrumb_items << {
            label: I18n.t("article_categories", scope: "decidim.admin.titles"),
            url: decidim_ad_users_space.admin_article_categories_path,
            active: true
          }
        end
      end
    end
  end
end
