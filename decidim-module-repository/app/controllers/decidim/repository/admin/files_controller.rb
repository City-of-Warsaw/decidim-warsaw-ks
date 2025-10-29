# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      # This controller is responsible for managing files in Admin Panel
      class FilesController < Decidim::Repository::Admin::ApplicationController
        def editor_images
          @form = form(SearchFileForm).from_params(params)

          enforce_permission_to :manage, :repository
          base_collection = filtered_collection.images_or_video
          base_collection = base_collection.where("decidim_repository_files.name ILIKE :q", q: "%#{@form.name}%") if @form.name.present?

          @files = base_collection.page(params[:page]).per(params[:per_page].presence || 16)
          render template: "decidim/repository/admin/files/editor_images", layout: false
        end

        def index
          enforce_permission_to :manage, :repository
          @files = filtered_collection
        end

        def show
          @file = file

          redirect_to(admin_files_path, alert: "Nie znaleziono pliku") unless file
        end

        def new
          enforce_permission_to :manage, :repository
          @form = form(FileNewForm).instance
          @form.folder_id = params[:admin_folder_id] if params[:admin_folder_id]

          @gallery = Decidim::Repository::Gallery.find(params[:admin_gallery_id]) if params[:admin_gallery_id]
        end

        def create
          enforce_permission_to :manage, :repository
          @form = form(FileNewForm).from_params(params)

          command = @form.add_to_gallery? ? AddFileToGallery : CreateFile
          command.call(@form, current_user) do
            on(:ok) do |file|
              message = I18n.t("files.create.success", scope: "decidim.repository.admin")

              respond_to do |format|
                format.html do
                  flash[:notice] = message
                  redirect_to redirect_after_create_or_destroy_path(
                    gallery_id: @form.admin_gallery_id,
                    folder_id: @form.folder_id
                  )
                end
                format.json do
                  render json: { message:, file_url: decidim_repository.blob_url(
                    file.file.signed_id,
                    filename: file.file.filename,
                    disposition: "attachment"
                  ) }
                end
              end
            end

            on(:invalid) do |file|
              message = I18n.t("files.create.error", scope: "decidim.repository.admin")

              respond_to do |format|
                format.html do
                  flash.now[:alert] = message
                  render :new
                end
                format.json do
                  # for duplicated record we return that duplicated file
                  if @form.duplicated_file
                    render json: { message:, file_url: decidim_repository.blob_url(
                      @form.duplicated_file.file.signed_id,
                      filename: @form.duplicated_file.file.filename,
                      disposition: "attachment"
                    ) }
                  else
                    render json: { message:, errors: file.errors.values.flatten }
                  end
                end
              end
            end
          end
        end

        def edit
          enforce_permission_to :manage, :repository
          @form = form(FileEditForm).from_model(file)
        end

        def update
          enforce_permission_to :manage, :repository
          @form = form(FileEditForm).from_params(params)
          @form.subaction = params[:subaction] if subaction_for?("save_as_copy")
          command = if subaction_for?("save_as_copy")
                      SaveAsCopyFile
                    else
                      UpdateFile
                    end

          command.call(file, @form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("files.update.success", scope: "decidim.repository.admin")
              redirect_to admin_files_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("files.update.error", scope: "decidim.repository.admin")
              render :edit
            end
          end
        end

        def destroy
          enforce_permission_to :manage, :repository

          if params[:admin_gallery_id]
            gallery_image = Decidim::Repository::GalleryImage.find_by gallery_id: params[:admin_gallery_id], file_id: file.id
            gallery_image.destroy
            flash[:notice] = I18n.t("galleries.destroy_gallery_file.success", scope: "decidim.repository.admin")
            redirect_to redirect_after_create_or_destroy_path(gallery_id: params[:admin_gallery_id])
          else
            DestroyFile.call(file, current_user) do
              on(:ok) do
                flash[:notice] = I18n.t("files.destroy.success", scope: "decidim.repository.admin")
                redirect_to redirect_after_create_or_destroy_path(gallery_id: params[:admin_gallery_id])
              end

              on(:invalid) do
                flash[:notice] = I18n.t("files.destroy.error", scope: "decidim.repository.admin")
                redirect_to redirect_after_create_or_destroy_path(gallery_id: params[:admin_gallery_id])
              end
            end
          end
        end

        private

        def tab_menu_name = :admin_repository_menu

        def file
          @file ||= collection.find_by(id: params[:id])
        end

        # returns collection for view handle by Decidim::Repository::Admin::Files::Filterable
        def collection
          @files ||= Decidim::Repository::File.where(decidim_organization_id: current_organization.id)
                                              .latest_first
                                              .with_attached_files
                                              .includes(:creator)
                                              .permitted_for_user(current_user)
        end

        # check if action is as searched
        def subaction_for?(subaction)
          params[:subaction] && params[:subaction] == subaction
        end

        def redirect_after_create_or_destroy_path(gallery_id: nil, folder_id: nil)
          if gallery_id.present?
            admin_gallery_path(gallery_id)
          elsif folder_id.present?
            admin_folder_path(folder_id)
          else
            admin_files_path
          end
        end
      end
    end
  end
end
