# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Repository
    # This is the engine that runs on the public interface of repository.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Repository

      routes do
        # for downloading blob from ActiveStorage with fixed https redirection
        get '/repository/blobs/:signed_id/*filename', to: "blobs#show", as: :blob

        # root to: "repository#index"
        scope "/admin" do
          resources :files, controller: 'admin/files', as: 'admin_files' do
            get :editor_images, on: :collection
          end
          resources :folders, controller: 'admin/folders', as: 'admin_folders' do
            resources :files, controller: 'admin/files'
          end
          resources :galleries, controller: 'admin/galleries', as: 'admin_galleries' do
            post :sort, on: :member

            resources :files, controller: 'admin/files'
          end
        end
      end

      initializer 'decidim_repository.append_routes', after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::Repository::Engine => '/'
        end
      end

      initializer "decidim.user_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :repository,
                        I18n.t("menu.repository", scope: "decidim.admin"),
                        decidim_repository.admin_files_path,
                        icon_name: "image-line",
                        position: 6.2,
                        active: is_active_link?(decidim_repository.admin_files_path, :inclusive) ||
                          is_active_link?(decidim_repository.admin_folders_path, :inclusive) ||
                          is_active_link?(decidim_repository.admin_galleries_path, :inclusive),
                        if: (!!current_user&.has_ad_role? && !current_user&.ad_expert?)
        end

        Decidim.menu :admin_repository_menu do |menu|
          menu.add_item :repository_galleries,
                        I18n.t("galleries.index.title", scope: "decidim.repository.admin"),
                        decidim_repository.admin_galleries_path,
                        position: 1,
                        icon_name: "image-line",
                        if: true,
                        active: is_active_link?(decidim_repository.admin_galleries_path)
          menu.add_item :folders_galleries,
                        I18n.t("folders.index.title", scope: "decidim.repository.admin"),
                        decidim_repository.admin_folders_path,
                        position: 1,
                        icon_name: "folder-open-line",
                        if: true,
                        active: is_active_link?(decidim_repository.admin_folders_path)
          menu.add_item :files_galleries,
                        I18n.t("files.index.title", scope: "decidim.repository.admin"),
                        decidim_repository.admin_files_path,
                        position: 1,
                        icon_name: "folder-line",
                        if: true,
                        active: is_active_link?(decidim_repository.admin_files_path)
        end
      end
    end
  end
end
