# frozen_string_literal: true

module Decidim
  module StudyNotes
    # This is the engine that runs on the public interface of `StudyNotes`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::StudyNotes::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        resources :categories, except: :show
        resources :map_backgrounds, except: :show
        resources :study_notes, only: [:index, :show] do
          get :export, on: :collection
        end
        resources :legend_items, except: :show
        root to: "study_notes#index"
      end

      def load_seed
        nil
      end
    end
  end
end
