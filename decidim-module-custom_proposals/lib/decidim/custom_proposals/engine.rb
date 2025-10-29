# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module CustomProposals
    # This is the engine that runs on the public interface of custom_proposals.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::CustomProposals

      routes do
        # Add engine routes here
        resources :custom_proposals, only: [:index, :show]
        root to: "custom_proposals#index"
      end

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::CustomProposals::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          load c
        end
      end

      initializer "decidim_custom_proposals.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::CustomProposals::Engine.root}/app/cells")
      end
    end
  end
end
