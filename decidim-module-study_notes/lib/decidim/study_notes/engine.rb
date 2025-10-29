# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module StudyNotes
    # This is the engine that runs on the public interface of study_notes.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::StudyNotes

      routes do
        get 'mapa-um/GraniceDzialek/findByNrObrAndNrDz/:nr_obr/:nr_dz', to: 'um_map#findByNrObrAndNrDz'
        resources :study_notes, only: [:index, :create, :show]
        root to: "study_notes#index"
      end

      initializer "decidim_study_notes.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::StudyNotes::Engine => "/"
        end
      end

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::StudyNotes::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          load c
        end
      end
    end
  end
end
