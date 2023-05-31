# frozen_string_literal: true

module Decidim::Repository
  # This controller is responsible for managing galleries in Admin Panel
  class Admin::GalleriesController < Decidim::Admin::ApplicationController
    helper Decidim::ApplicationHelper
    helper Decidim::Repository::Admin::FilesHelper
    layout "decidim/admin/repository"

    def index
      enforce_permission_to :manage, :repository
      @galleries = collection.page(params[:page]).per(15)
    end

    def show
      enforce_permission_to :manage, :repository
      @files = gallery.files.permitted_for_user(current_user)
    end

    def new
      enforce_permission_to :manage, :repository
      @form = form(Decidim::Repository::Admin::GalleryForm).instance
    end

    def create
      enforce_permission_to :manage, :repository
      @form = form(Decidim::Repository::Admin::GalleryForm).from_params(params)

      Decidim::Repository::Admin::CreateGallery.call(@form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("galleries.create.success", scope: "decidim.repository.admin")
          redirect_to admin_galleries_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("galleries.create.error", scope: "decidim.repository.admin")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :manage, :repository
      @form = form(Decidim::Repository::Admin::GalleryForm).from_model(gallery)
    end

    def update
      enforce_permission_to :manage, :repository
      @form = form(Decidim::Repository::Admin::GalleryForm).from_params(params)

      Decidim::Repository::Admin::UpdateGallery.call(gallery, @form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("galleries.update.success", scope: "decidim.repository.admin")
          redirect_to admin_gallery_path(gallery)
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("galleries.update.error", scope: "decidim.repository.admin")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :manage, :repository
      # if gallery.published?
      #   flash[:alert] = "Nie można usunąć opublikowanego ..."
      # else
      gallery.destroy
      flash[:notice] = I18n.t("galleries.destroy.success", scope: "decidim.repository.admin")
      # end
      redirect_to admin_galleries_path
    end

    def sort
      gallery.gallery_images.each do |gi|
        new_position = params[:sort_ids].index(gi.file_id.to_s) + 1
        gi.update_column(:position, new_position)
      end
    end

    private

    def gallery
      @gallery ||= collection.find_by(id: params[:id])
    end

    def collection
      Gallery.where(decidim_organization_id: current_organization.id).latest_first
    end
  end
end
