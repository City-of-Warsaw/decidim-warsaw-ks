# frozen_string_literal: true

module Decidim
  module PagesExtended
    module Admin
      class PagesController < Decidim::Admin::Components::BaseController
        # include Rails.application.routes.mounted_helpers
        helper Decidim::ApplicationHelper
        # helper Decidim::Admin::MenuHelper
        helper Decidim::PagesExtended::ApplicationHelper
        include Decidim::PagesExtended::ApplicationHelper
        helper_method :pages, :page

        def index
          enforce_permission_to :read, :page
        end

        def new
          enforce_permission_to :create, :page

          @form = form(Decidim::Pages::Admin::PageForm).instance
        end

        def create
          enforce_permission_to :create, :page
          @form = form(Decidim::Pages::Admin::PageForm).from_params(params, current_component: current_component)

          Decidim::PagesExtended::Admin::CreatePage.call(@form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("posts.create.success", scope: "decidim.blogs.admin")
              redirect_to index_pages_extended_path(current_component)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("posts.create.invalid", scope: "decidim.blogs.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :page

          @form = form(Decidim::Pages::Admin::PageForm).from_model(page)
        end

        def update
          enforce_permission_to :update, :page

          @form = form(Decidim::Pages::Admin::PageForm).from_params(params)

          Decidim::Pages::Admin::UpdatePage.call(@form, page) do
            on(:ok) do
              flash[:notice] = I18n.t("pages.update.success", scope: "decidim.pages.admin")
              redirect_to index_pages_extended_path(current_component)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("pages.update.invalid", scope: "decidim.pages.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :page, page: page
          page.destroy!

          flash[:notice] = I18n.t("pages.destroy.success", scope: "decidim.pages.admin")

          redirect_to index_pages_extended_path(current_component)
        end

        def publish
          enforce_permission_to :publish, :page, page: page
          # page.destroy!
          #
          # flash[:notice] = I18n.t("pages.publish.success", scope: "decidim.pages.admin")
          Decidim::PagesExtended::Admin::TogglePublishPage.call(page, current_user)

          flash[:notice] = I18n.t("pages.destroy.success", scope: "decidim.pages.admin")

          redirect_to index_pages_extended_path(current_component)
        end

        private

        def current_component
          Decidim::Component.find_by(id: params[:component_id])
        end

        def current_participatory_space
          current_component.participatory_space
        end

        def pages
          @pages ||= Decidim::Pages::Page.where(component: current_component).order(title: :asc).page(params[:page]).per(15)
        end

        def page
          @page ||= Decidim::Pages::Page.where(component: current_component).find(params[:id]) if params[:id]
        end
      end
    end
  end
end
