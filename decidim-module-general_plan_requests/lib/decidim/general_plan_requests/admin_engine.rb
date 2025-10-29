# frozen_string_literal: true

module Decidim
  module GeneralPlanRequests
    # This is the engine that runs on the public interface of `GeneralPlanRequests`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::GeneralPlanRequests::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        resources :general_plan_requests, only: [:index, :show] do
          get :pdf, on: :member
          post :register_to_signum, on: :member
          get :export, on: :collection
        end
        root to: "general_plan_requests#index"
      end

      def load_seed
        nil
      end
    end
  end
end
