# frozen_string_literal: true

module Decidim
  module Remarks
    # This is the engine that runs on the public interface of `Remarks`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Remarks::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        resources :remarks, only: [:index, :edit, :update] do
          get :export, on: :collection
        end

        root to: "remarks#index"
      end

      def load_seed
        nil
      end
    end
  end
end
