# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module CustomAi
    # This is the engine that runs on the public interface of custom_ai.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::CustomAi

      routes do
        scope "/processes/:participatory_process_slug/f/:component_id" do
          post "/ai_api/:name", to: "api#api"
        end
      end

      initializer "decidim_custom_ai.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::CustomAi::Engine => '/'
        end
      end

      initializer "CustomAi.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_custom_ai.register_icons" do
        Decidim.icons.register(name: "ai", icon: "ai", category: "system", description: "", engine: :custom_ai)
        Decidim.icons.register(name: "ai-slash", icon: "ai-slash", category: "system", description: "", engine: :custom_ai)
        Decidim.icons.register(name: "sparkling-2-fill", icon: "sparkling-2-fill", category: "system", description: "", engine: :custom_ai)
        Decidim.icons.register(name: "loader-4-line", icon: "loader-4-line", category: "system", description: "", engine: :custom_ai)
        Decidim.icons.register(name: "ai-lighbulb", icon: "ai-lighbulb", category: "system", description: "", engine: :custom_ai)
      end

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::CustomAi::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          load c
        end
      end
    end
  end
end
