# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module ConsultationMap
    # This is the engine that runs on the public interface of consultation_map.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ConsultationMap

      routes do
        # Add engine routes here
        resources :remarks, except: :destroy do
          patch :second_step_update, on: :member
        end
        root to: "remarks#index"
      end

      initializer "decidim_consultation_map.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::ConsultationMap::Engine => "/"
        end
      end

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::ConsultationMap::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          load c
        end
      end

      initializer "decidim_consultation_map.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ConsultationMap::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ConsultationMap::Engine.root}/app/views") # for partials
      end
    end
  end
end
