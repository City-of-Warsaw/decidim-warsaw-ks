# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      # This controller is responsible for managing folders in Admin Panel
      class FoldersController < Decidim::Repository::Admin::ApplicationController
        def index
          enforce_permission_to :manage, :repository
          @folders = filtered_collection
        end

        def show
          enforce_permission_to :manage, :repository
          @files = filtered_collection
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
          folder.destroy
          flash[:notice] = I18n.t("folders.destroy.success", scope: "decidim.repository.admin")
          redirect_to admin_folders_path
        end

        private

        def tab_menu_name = :admin_repository_menu

        # returns base collection used for raw data aggregation
        def folders
          @folders ||= Decidim::Repository::Folder.where(decidim_organization_id: current_organization.id).latest_first
        end

        def folder
          @folder ||= folders.find_by(id: params[:id])
        end

        # returns collection for view handle by Decidim::Admin::Filterable
        def collection
          @collection ||= if action_name == "show"
                            folder.files.permitted_for_user(current_user)
                          else
                            folders
                          end
        end
      end
    end
  end
end
