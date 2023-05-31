# frozen_string_literal: true

module Decidim::Repository
  # This controller is responsible for managing galleries in Admin Panel
  class Admin::FoldersController < Decidim::Admin::ApplicationController
    helper Decidim::ApplicationHelper
    layout "decidim/admin/repository"

    def index
      enforce_permission_to :manage, :repository
      @folders = collection.page(params[:page]).per(15)
    end

    def show
      enforce_permission_to :manage, :repository
      @files = folder.files.permitted_for_user(current_user)
    end

    def new
      enforce_permission_to :manage, :repository
      @form = form(Decidim::Repository::Admin::FolderForm).instance
    end

    def create
      enforce_permission_to :manage, :repository
      @form = form(Decidim::Repository::Admin::FolderForm).from_params(params)

      Decidim::Repository::Admin::CreateFolder.call(@form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("folders.create.success", scope: "decidim.repository.admin")
          redirect_to admin_folders_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("folders.create.error", scope: "decidim.repository.admin")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :manage, :repository
      @form = form(Decidim::Repository::Admin::FolderForm).from_model(folder)
    end

    def update
      enforce_permission_to :manage, :repository
      @form = form(Decidim::Repository::Admin::FolderForm).from_params(params)

      Decidim::Repository::Admin::UpdateFolder.call(folder, @form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("folders.update.success", scope: "decidim.repository.admin")
          redirect_to admin_folders_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("folders.update.error", scope: "decidim.repository.admin")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :manage, :repository
      # if folder.published?
      #   flash[:alert] = "Nie można usunąć opublikowanego ..."
      # else
        folder.destroy
        flash[:notice] = I18n.t("folders.destroy.success", scope: "decidim.repository.admin")
      # end
      redirect_to admin_folders_path
    end


    private

    def folder
      @folder ||= collection.find_by(id: params[:id])
    end

    def collection
      Folder.where(decidim_organization_id: current_organization.id).latest_first
    end
  end
end
