# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module AdUsersSpace
    # This is the engine that runs on the public interface of ad_users_space.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::AdUsersSpace

      initializer "decidim.menu" do
        # Decidim.menu :menu do |menu|
        #   menu.item I18n.t("menu.forum", scope: "decidim"),
        #             decidim_ad_users_space.forum_articles_path,
        #             position: 8,
        #             active: :inclusive,
        #             if: !!(current_user && current_user.has_ad_role?)
        # end
        #
        # Decidim.menu :menu do |menu|
        #   menu.item I18n.t("menu.info", scope: "decidim"),
        #             decidim_ad_users_space.info_articles_path,
        #             position: 9,
        #             active: :inclusive,
        #             if: !!(current_user && current_user.has_ad_role?)
        # end

        Decidim.menu :menu do |menu|
          menu.item I18n.t("menu.ad_users_space", scope: "decidim"),
                    decidim_ad_users_space.info_articles_path,
                    position: 9,
                    active: is_active_link?(decidim_ad_users_space.info_articles_path, :inclusive) ||
                            is_active_link?(decidim_ad_users_space.forum_articles_path, :inclusive),
                    if: !!current_user&.has_ad_role?
        end
      end

      initializer "decidim.user_menu" do
        # Decidim.menu :admin_menu do |menu|
        #   menu.item I18n.t("menu.forum", scope: "decidim.admin"),
        #             decidim_ad_users_space.admin_forum_articles_path,
        #             icon_name: "lightbulb",
        #             position: 5.1,
        #             active: is_active_link?(decidim_ad_users_space.admin_forum_articles_path, :inclusive),
        #             if: current_user.ad_admin?
        # end

        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.info", scope: "decidim.admin"),
                    decidim_ad_users_space.admin_info_articles_path,
                    icon_name: "justify-left",
                    position: 5.2,
                    active: is_active_link?(decidim_ad_users_space.admin_info_articles_path, :inclusive) ||
                            is_active_link?(decidim_ad_users_space.admin_article_categories_path, :inclusive),
                    if: current_user.ad_admin?
        end
      end

      initializer "decidim_ad_users_space.register_resources" do
        Decidim.register_resource(:forum_article) do |resource|
          resource.model_class_name = "Decidim::AdUsersSpace::ForumArticle"
          resource.card = "decidim/ad_users_space/forum_article"
          resource.searchable = false
        end
        Decidim.register_resource(:info_article) do |resource|
          resource.model_class_name = "Decidim::AdUsersSpace::InfoArticle"
          resource.card = "decidim/ad_users_space/info_article"
          resource.searchable = false
        end
      end

      routes do
        scope '/admin' do
          resources :forum_articles, controller: 'admin/forum_articles', as: 'admin_forum_articles' do
            # resources :attachment_collections, controller: 'admin/attachment_collections', as: 'attachment_collections'
            # resources :attachments, controller: 'admin/attachments', as: 'attachments'
          end

          resources :article_categories, controller: 'admin/article_categories', as: 'admin_article_categories'
          resources :info_articles, controller: 'admin/info_articles', as: 'admin_info_articles' do
            # resources :attachment_collections, controller: 'admin/attachment_collections', as: 'attachment_collections'
            # resources :attachments, controller: 'admin/attachments', as: 'attachments'
          end
        end

        resources :forum_articles, except: [:destroy], as: 'forum_articles'
        resources :info_articles, only: [:index, :show], as: 'info_articles'
      end

      initializer 'decidim_ad_users_space.append_routes', after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::AdUsersSpace::Engine => '/'
        end
      end

      initializer "decidim_ad_users_space.assets" do |app|
        app.config.assets.precompile += %w[decidim_ad_users_space_manifest.js decidim_ad_users_space_manifest.css]
      end

      # add cells views paths
      initializer "decidim_ad_users_space.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::AdUsersSpace::Engine.root}/app/cells")
      end
    end
  end
end
