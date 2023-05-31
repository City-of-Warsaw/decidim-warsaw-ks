# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module StudyNotes
    # This is the engine that runs on the public interface of study_notes.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::StudyNotes

      routes do
        # Add engine routes here
        resources :study_notes, only: [:index, :create, :show]
        root to: "study_notes#index"
      end

      initializer "decidim_study_notes.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::StudyNotes::Engine => "/"
        end
      end

      # decorators
      config.autoload_paths << File.join(
        Decidim::StudyNotes::Engine.root, "app", "decorators", "{**}"
      )

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::StudyNotes::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          require_dependency(c)
        end
      end

      initializer "decidim_study_notes.assets" do |app|
        app.config.assets.precompile += %w[decidim_study_notes_manifest.js decidim/study_notes/admin/leaflet.draw.modCS.js decidim/study_notes/admin/leaflet-src.1.8.0.modCS.js decidim/study_notes/admin/geojson-map.js.erb  decidim_study_notes_manifest.css geojson-map/images/marker-icon.png geojson-map/images/marker-shadow.png leaflet.css]
      end
    end
  end
end
