# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module WsNotification
    # This is the engine that runs on the public interface of ws_notification.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::WsNotification

      initializer "decidim.user_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.ws_messages", scope: "decidim.admin"),
                    decidim_ws_notification.admin_ws_messages_path,
                    icon_name: "document",
                    position: 6.7,
                    active: is_active_link?(decidim_ws_notification.admin_ws_messages_path, :inclusive),
                    if: allowed_to?(:update, :organization, organization: current_organization)
        end
      end

      routes do
        scope "/admin" do
          resources :ws_messages, controller: 'admin/ws_messages', as: 'admin_ws_messages' do
            post :publish, on: :member
          end
        end
      end

      initializer "decidim_ws_notification.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::WsNotification::Engine => "/"
        end
      end

      initializer "decidim_ws_notification.assets" do |app|
        app.config.assets.precompile += %w[decidim_ws_notification_manifest.js decidim_ws_notification_manifest.css]
      end
    end
  end
end
