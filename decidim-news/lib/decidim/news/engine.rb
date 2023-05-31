module Decidim
  module News
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::News

      initializer "decidim.menu" do
        Decidim.menu :menu do |menu|
          menu.item I18n.t("menu.news", scope: "decidim"),
                    decidim_news.news_index_path,
                    position: 6,
                    active: :inclusive
        end
      end

      initializer "decidim.user_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.news", scope: "decidim.admin"),
                    decidim_news.informations_path,
                    icon_name: "info",
                    position: 4.6,
                    active: is_active_link?(decidim_news.informations_path, :inclusive),
                    if: allowed_to?(:update, :organization, organization: current_organization)
        end
      end

      initializer "decidim_news.content_blocks" do
        Decidim.content_blocks.register(:homepage, :latest_informations) do |content_block|
          content_block.cell = "decidim/news/content_blocks/latest_informations"
          content_block.public_name_key = "decidim.news.content_blocks.latest_informations.name"
          content_block.default!
        end
      end

      initializer "decidim_news.register_resources" do
        Decidim.register_resource(:information) do |resource|
          resource.model_class_name = "Decidim::News::Information"
          resource.card = "decidim/news/information"
          resource.searchable = true
        end
      end

      routes do
        scope "/admin" do
          resources :informations, controller: 'admin/informations' do
            resources :attachment_collections, controller: 'admin/attachment_collections', as: 'attachment_collections'
            resources :attachments, controller: 'admin/attachments', as: 'attachments'
          end
        end
        resources :informations, only: [:index, :show], as: 'news'
      end

      initializer "decidim_news.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::News::Engine => "/"
        end
      end

      # decorators
      config.autoload_paths << File.join(
        Decidim::News::Engine.root, "app", "decorators", "{**}"
      )

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::News::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          require_dependency(c)
        end
      end

      # add cells views paths
      initializer "decidim_news.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::News::Engine.root}/app/cells")
      end
    end
  end
end
