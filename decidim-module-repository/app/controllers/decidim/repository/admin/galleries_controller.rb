# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      # This controller is responsible for managing galleries in Admin Panel
      class GalleriesController < Decidim::Repository::Admin::ApplicationController
        def index
          enforce_permission_to :manage, :repository
          @galleries = filtered_collection
        end

        def show
          enforce_permission_to :manage, :repository
          @files = filtered_collection
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
          Decidim::Repository::Admin::DestroyGallery.call(gallery, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("galleries.destroy.success", scope: "decidim.repository.admin")
              redirect_to admin_galleries_path
            end
          end
        end

        def sort
          gallery.gallery_images.each do |gi|
            new_position = params[:sort_ids].index(gi.file_id.to_s) + 1
            gi.update_column(:position, new_position)
          end
        end

        private

        def tab_menu_name = :admin_repository_menu

        # returns base collection used for raw data aggregation
        def galleries
          @galleries ||= Decidim::Repository::Gallery.where(decidim_organization_id: current_organization.id)
                                                     .latest_first
        end

        def gallery
          @gallery ||= galleries.find_by(id: params[:id])
        end

        # returns collection for view handle by Decidim::Admin::Filterable
        def collection
          @collection ||= if action_name == "show"
                            gallery.files.permitted_for_user(current_user)
                          else
                            galleries
                          end
        end

        def search_field_predicate
          if action_name == "show"
            # for gallery files, use the same search just as for index files
            :name_or_description_cont
          else
            # for gallery, its own search
            :name_cont
          end
        end
      end
    end
  end
end
