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
          menu.item I18n.t("menu.repository", scope: "decidim.admin"),
                    decidim_repository.admin_files_path,
                    icon_name: "camera-slr",
                    position: 6.2,
                    active: is_active_link?(decidim_repository.admin_files_path, :inclusive) ||
                      is_active_link?(decidim_repository.admin_folders_path, :inclusive) ||
                      is_active_link?(decidim_repository.admin_galleries_path, :inclusive),
                    if: (!!current_user&.has_ad_role? && !current_user&.ad_expert?)
        end
      end

      initializer "decidim_repository.assets" do |app|
        app.config.assets.precompile += %w[decidim_repository_manifest.js
                                          decidim_repository_manifest.css
                                          decidim/repository/admin/jquery.MultiFile.js
                                          decidim/repository/admin/image-editor.1.0.0.js
                                          decidim/repository/admin/image-editor.1.1.0.js
                                          decidim/repository/admin/image-editor.1.2.1.js
                                          decidim/repository/admin/video.min.js
                                          decidim/repository/admin/video-js.css
                                          decidim/repository/admin/video-js-pl.js]
      end
    end
  end
end
