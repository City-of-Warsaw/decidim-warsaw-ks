# frozen_string_literal: true

module Decidim
  module Repository
    # This is the engine that runs on the public interface of `Repository`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Repository::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :repository do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "repository#index"
      end

      def load_seed
        nil
      end
    end
  end
end
