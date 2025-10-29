# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module GeneralPlanRequests
    # This is the engine that runs on the public interface of general_plan_requests.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::GeneralPlanRequests

      routes do
        resources :general_plan_requests, only: [:index, :create]
        get 'general_plan_request/:uuid' => '/decidim/general_plan_requests/general_plan_requests#show', as: :general_plan_request
        root to: "general_plan_requests#index"
      end

      initializer "decidim_general_plan_requests.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::GeneralPlanRequests::Engine => "/"
        end
      end

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::GeneralPlanRequests::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          load c
        end
      end
    end
  end
end
