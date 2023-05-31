# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module ExpertQuestions
    # This is the engine that runs on the public interface of expert_questions.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ExpertQuestions

      routes do
        # Add engine routes here
        resources :user_questions, except: :destroy do
          patch :second_step_update, on: :member
        end
        root to: "user_questions#index"
      end

      # decorators
      config.autoload_paths << File.join(
        Decidim::ExpertQuestions::Engine.root, "app", "decorators", "{**}"
      )

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::ExpertQuestions::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          require_dependency(c)
        end
      end

      initializer "decidim_expert_questions.assets" do |app|
        app.config.assets.precompile += %w[decidim_expert_questions_manifest.js decidim_expert_questions_manifest.css]
      end

      initializer "decidim_expert_questions.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ExpertQuestions::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ExpertQuestions::Engine.root}/app/views") # for partials
      end
    end
  end
end
