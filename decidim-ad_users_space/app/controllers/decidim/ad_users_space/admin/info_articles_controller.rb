# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    module Admin
      # This controller is responsible for managing Info Articles in Admin Panel
      class InfoArticlesController < Decidim::Admin::ApplicationController
        helper Decidim::ApplicationHelper
        layout "decidim/admin/info_articles"

        def index
          enforce_permission_to :update, :organization
          @info_articles = collection.page(params[:page]).per(15)
        end

        def new
          enforce_permission_to :update, :organization
          @form = form(Decidim::AdUsersSpace::Admin::InfoArticleForm).instance
        end

        def create
          enforce_permission_to :update, :organization
          @form = form(Decidim::AdUsersSpace::Admin::InfoArticleForm).from_params(params)

          Decidim::AdUsersSpace::Admin::CreateInfoArticle.call(@form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("info_articles.create.success", scope: "decidim.admin")
              redirect_to admin_info_articles_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("info_articles.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :organization
          @form = form(Decidim::AdUsersSpace::Admin::InfoArticleForm).from_model(info_article)
        end

        def update
          enforce_permission_to :update, :organization
          @form = form(Decidim::AdUsersSpace::Admin::InfoArticleForm).from_params(params)

          Decidim::AdUsersSpace::Admin::UpdateInfoArticle.call(info_article, @form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("info_articles.update.success", scope: "decidim.admin")
              redirect_to admin_info_articles_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("info_articles.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        def destroy
          enforce_permission_to :update, :organization

          Decidim::AdUsersSpace::Admin::DestroyInfoArticle.call(info_article, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("info_articles.destroy.success", scope: "decidim.admin")
              redirect_to admin_info_articles_path
            end
          end
        end

        private

        def info_article
          @info_article ||= collection.find_by(id: params[:id])
        end

        def collection
          InfoArticle.where(decidim_organization_id: current_organization.id)
          # current_organization.info_articles
        end
      end
    end
  end
end
