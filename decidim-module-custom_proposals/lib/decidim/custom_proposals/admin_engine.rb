# frozen_string_literal: true

module Decidim
  module CustomProposals
    # This is the engine that runs on the public interface of `CustomProposals`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::CustomProposals::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        resources :custom_proposals, except: [:show] do
          get :export, on: :collection
        end
        root to: "custom_proposals#index"
      end

      def load_seed
        nil
      end
    end
  end
end
