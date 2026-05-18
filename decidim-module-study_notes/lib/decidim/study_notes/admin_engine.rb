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
          get :export_zip, on: :collection
          get :export_selected, on: :collection
          get :export_zip_selected, on: :collection
          get :get_file, on: :collection
          get :sequential_numbers, on: :collection
          post :generate_sequential_numbers, on: :collection
          get :map, on: :collection
          post :register_to_signum, on: :member
          get :register_selected_to_signum, on: :collection
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
