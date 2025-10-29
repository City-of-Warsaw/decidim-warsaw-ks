# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Remarks
    # This is the engine that runs on the public interface of remarks.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Remarks

      routes do
        # Add engine routes here
        resources :remarks, except: :new do
          member do
            post :vote
            patch :second_step_update
          end
        end
        root to: "remarks#index"
      end

      initializer "decidim_remarks.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::Remarks::Engine => "/"
        end
      end

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::Remarks::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          load c
        end
      end

      initializer "decidim_remarks.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Remarks::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Remarks::Engine.root}/app/views") # for partials
      end
    end
  end
end
