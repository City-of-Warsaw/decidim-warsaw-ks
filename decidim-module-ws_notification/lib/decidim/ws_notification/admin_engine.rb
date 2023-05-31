# frozen_string_literal: true

module Decidim
  module WsNotification
    # This is the engine that runs on the public interface of `WsNotification`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::WsNotification::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :ws_notification do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "ws_notification#index"
      end

      def load_seed
        nil
      end
    end
  end
end
