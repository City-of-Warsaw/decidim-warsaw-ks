# frozen_string_literal: true

require "rails"
require "decidim/core"
require "apipie-rails"

module Decidim
  module RestApi
    # This is the engine that runs on the public interface of rest_api.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::RestApi

      routes do
        # Add engine routes here
        scope '/rest-api' do
          resources :categories, only: [:index]
          resources :districts, only: [:index]
          resources :participatory_processes, only: [:show, :index]
        end
        # Endpoint with no authentication for test only
        unless Rails.env.production?
          scope '/rest-api-no-auth', noauth: true do
            resources :categories, only: [:index]
            resources :districts, only: [:index]
            resources :participatory_processes, only: [:show, :index]
          end
        end
      end

      initializer "decidim_rest_api.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::RestApi::Engine => "/"

          # routing for apipie gem
          apipie
        end
      end

      # TODO: For Version 0.25.2
      # initializer "RestApi.webpacker.assets_path" do
      #   Decidim.register_assets_path File.expand_path("app/packs", root)
      # end

      initializer "decidim_rest_api.append_routes", after: :load_config_initializers do |_app|
        # config for apipie gem
        Apipie.configure do |config|
          config.app_name                = "Decidim Warszawa KS"
          config.api_base_url            = "/rest-api"
          config.doc_base_url            = "/rest-api-doc"
          config.api_controllers_matcher = "#{Rails.root}/decidim-module-rest_api/app/controllers/decidim/**/*.rb"
          config.default_locale = 'pl'
          config.app_info = "REST API dla Decidim Warszawa KS. Dostęp do API wymaga przekazania w nagłówku zapytania poprawnego tokenu X-Api-Key"
        end
      end

    end
  end
end
