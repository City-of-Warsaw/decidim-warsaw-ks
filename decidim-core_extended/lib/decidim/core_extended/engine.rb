# frozen_string_literal: true

module Decidim
  module CoreExtended
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::CoreExtended

      routes do
        resources :email_follows, only: :create
      end

      initializer "decidim_core_extended.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::CoreExtended::Engine => "/"
        end
      end

      initializer "decidim.core_extended.register_resources" do
        Decidim.register_resource(:static_page) do |resource|
          resource.model_class_name = "Decidim::StaticPage"
          resource.card = "decidim/pages"
          resource.searchable = true
        end
      end

      # remove elements from search
      unsearchable_resources_manifest_names = %w[
        assembly initiative conference consultation voting
        blogpost budget project debate
      ]
      unsearchable_resources_manifest_names.each do |manifest_name|
        resourcable = Decidim.find_resource_manifest(manifest_name)
        resourcable.searchable = false if resourcable
      end

      # Decidim::MenuRegistry.destroy(:admin_assemblies_menu)

      # assets
      initializer 'decidim_core_extended.assets.precompile' do |app|
        app.config.assets.precompile += %w[decidim/core_extended/debates-icon.png
                                           decidim/core_extended/meetings-icon.png decidim/core_extended/proposals-icon.png
                                           decidim/core_extended/decidim-logo-black.png]
      end

      config.autoload_paths << File.join(
        Decidim::CoreExtended::Engine.root, 'app', 'decorators', '{**}'
      )

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::CoreExtended::Engine.root + 'app/decorators/**/*_decorator*.rb').each do |c|
          require_dependency(c)
        end
      end

      # cells
	    initializer 'decidim_core_extended.add_cells_view_paths' do
	       Cell::ViewModel.view_paths << File.expand_path("#{Decidim::CoreExtended::Engine.root}/app/cells")
         Cell::ViewModel.view_paths << File.expand_path("#{Decidim::CoreExtended::Engine.root}/app/views")
      end

      initializer "decidim.core.homepage_content_blocks", after: :load_config_initializers do |_app|
        hero_cb = Decidim.content_blocks.for(:homepage).detect do |v|
          v.name == :hero
        end

        hero_cb.settings do |settings|
          settings.attribute :addition_to_welcome_text, type: :text, translated: true
          settings.attribute :hero_image_alt, type: :text
        end
      end
    end
  end
end
