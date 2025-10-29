# frozen_string_literal: true

module Decidim
  module News
    # The engine that runs on the admin AND public interface of `News` module.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::News

      initializer 'decidim.menu' do
        Decidim.menu :menu do |menu|
          menu.add_item :news,
                        'Informacje', # sys_name for MainMenuItem
                        decidim_news.news_index_path,
                        position: 6,
                        active: :inclusive
        end
      end

      Decidim.menu :home_content_block_menu do |menu|
        menu.add_item :news,
                      'Aktualności', # sys_name for MainMenuItem
                      decidim_news.news_index_path,
                      position: 6,
                      active: :inclusive
      end

      initializer 'decidim.user_menu' do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :admin_informations,
                        'Informacje', # here we not use it as sys_name for MainMenuItem
                        decidim_news.informations_path,
                        icon_name: 'information-line',
                        position: 4.6,
                        active: is_active_link?(decidim_news.informations_path, :inclusive),
                        if: allowed_to?(:update, :organization, organization: current_organization)
        end
      end

      initializer 'decidim_news.content_blocks' do
        Decidim.content_blocks.register(:homepage, :latest_informations) do |content_block|
          content_block.cell = 'decidim/news/content_blocks/latest_informations'
          content_block.public_name_key = 'decidim.news.content_blocks.latest_informations.name'
          content_block.default!
        end
      end

      initializer 'decidim_news.register_resources' do
        Decidim.register_resource(:information) do |resource|
          resource.model_class_name = 'Decidim::News::Information'
          resource.card = 'decidim/news/information'
          resource.searchable = true
        end
      end

      routes do
        scope '/admin' do
          resources :informations, controller: 'admin/informations', except: :show do
            member do
              patch :publish
              patch :unpublish
            end
            resources :attachment_collections, controller: 'admin/attachment_collections', as: 'attachment_collections'
            resources :attachments, controller: 'admin/attachments', as: 'attachments'
          end
        end

        resources :informations, only: %i[index show], as: 'news'
      end

      initializer 'decidim_news.append_routes', after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::News::Engine => '/'
        end
      end

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::News::Engine.root + 'app/decorators/**/*_decorator*.rb').each do |c|
          load c
        end
      end

      # add cells views paths
      initializer 'decidim_news.add_cells_view_paths' do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::News::Engine.root}/app/cells")
      end
    end
  end
end
