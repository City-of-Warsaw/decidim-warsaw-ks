# frozen_string_literal: true

require_dependency "decidim/components/namer"
require_dependency "decidim/users_extended"

module Decidim
  module PagesExtended
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::PagesExtended
      # include Decidim::PagesExtended::AdminEngine

      component = Decidim.find_component_manifest('pages')
      # component.admin_engine = Decidim::Pages::AdminEngine
      component.data_portable_entities = ["Decidim::Pages::Page"]
      component.permissions_class_name = "Decidim::PagesExtended::Permissions"
      component.settings(:global) do |settings|
        settings.attribute :help_section, type: :text, translated: true, editor: true
      end

      resource = Decidim.find_resource_manifest('page')
      # resource.model_class_name = "Decidim::Pages::Page"
      # resource.template = "decidim/pages_extended/page"
      resource.card = "decidim/pages_extended/page"
      # resource.reported_content_cell = "decidim/meetings/reported_content"
      resource.actions = %w(read create publish update destroy)
      resource.searchable = true

      component.register_stat :all_pages_count, primary: true, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, _start_at, _end_at|
        Decidim::Pages::Page.where(component: components).count
      end

      component.on(:create) do |instance|
        # removing automatic creation of page
        return
      end

      component.on(:copy) do |context|
        # unable copying
        return
      end

      routes do
        ### need to be added in main app routes
        scope 'admin/participatory_processes/:participatory_process_slug/f/:component_id' do
          resources :pages, controller: 'admin/pages', as: 'participatory_process_slug_pages' do
            post :publish, on: :member
          end
        end
        scope 'admin/assemblies/:assembly_slug/f/:component_id' do
          resources :pages, controller: 'admin/pages', as: 'assemblies_slug_pages' do
            post :publish, on: :member
          end
        end
      end

      initializer "decidim_pages_extended.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::PagesExtended::Engine => "/", at: '/'
        end
      end

      # assets
      initializer "decidim_pages_extended.assets.precompile" do |app|
        app.config.assets.precompile += %w(decidim/pages_extended/admin/destroy_page_alert.js)
      end

      config.autoload_paths << File.join(
        Decidim::PagesExtended::Engine.root, "app", "decorators", "{**}"
      )

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::PagesExtended::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          require_dependency(c)
        end
      end

      # cells
	    initializer "decidim_pages_extended.add_cells_view_paths" do
	       Cell::ViewModel.view_paths << File.expand_path("#{Decidim::PagesExtended::Engine.root}/app/cells")
         Cell::ViewModel.view_paths << File.expand_path("#{Decidim::PagesExtended::Engine.root}/app/views")
      end
    end
  end
end
