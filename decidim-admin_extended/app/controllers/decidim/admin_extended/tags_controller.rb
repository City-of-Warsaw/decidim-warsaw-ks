require_dependency "decidim/admin_extended/application_controller"

module Decidim::AdminExtended
  class TagsController < ApplicationController
    layout "decidim/admin/settings"

    def index
      enforce_permission_to :update, :organization, organization: current_organization

      @items = Decidim::AdminExtended::Tag.all
    end

    def new
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::TagForm).instance
    end

    def create
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::TagForm).from_params(params)

      Decidim::AdminExtended::CreateTag.call(@form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("tags.create.success", scope: "decidim.admin_extended")
          redirect_to decidim_admin_extended.tags_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("tags.create.error", scope: "decidim.admin_extended")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::TagForm).from_model(tag)
    end

    def update
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::TagForm).from_params(params)

      Decidim::AdminExtended::UpdateTag.call(tag, @form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("tags.update.success", scope: "decidim.admin_extended")
          redirect_to decidim_admin_extended.tags_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("tags.update.error", scope: "decidim.admin_extended")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :update, :organization, organization: current_organization

      Decidim::AdminExtended::DestroyTag.call(tag, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("tags.destroy.success", scope: "decidim.admin_extended")
          redirect_to tags_path
        end
        on(:has_spaces) do
          flash[:alert] = I18n.t("tags.destroy.has_spaces", scope: "decidim.admin_extended")
          redirect_to tags_path
        end
      end
    end

    private

    def tag
      Decidim::AdminExtended::Tag.find(params[:id])
    end
  end
end
