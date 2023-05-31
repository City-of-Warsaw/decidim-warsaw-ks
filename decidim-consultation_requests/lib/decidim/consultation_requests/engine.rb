# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module ConsultationRequests
    # This is the engine that runs on the public interface of consultation_requests.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ConsultationRequests

      initializer "decidim.menu" do
        Decidim.menu :menu do |menu|
          menu.item I18n.t("menu.consultation_requests", scope: "decidim"),
                    decidim_consultation_requests.consultation_requests_path,
                    position: 7,
                    active: :inclusive
        end
      end

      initializer "decidim.user_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.consultation_requests", scope: "decidim.admin"),
                    decidim_consultation_requests.admin_consultation_requests_path,
                    icon_name: "document",
                    position: 4.7,
                    active: is_active_link?(decidim_consultation_requests.admin_consultation_requests_path, :inclusive),
                    if: allowed_to?(:update, :organization, organization: current_organization)
        end
      end

      # initializer "decidim_consultation_requests.content_blocks" do
      #   Decidim.content_blocks.register(:homepage, :latest_consultation_requests) do |content_block|
      #     content_block.cell = "decidim/consultation_requests/content_blocks/latest_consultation_requests"
      #     content_block.public_name_key = "decidim.consultation_requests.content_blocks.latest_consultation_requests.name"
      #     content_block.default!
      #   end
      # end

      initializer "decidim_consultation_requests.register_resources" do
        Decidim.register_resource(:consultation_request) do |resource|
          resource.model_class_name = "Decidim::ConsultationRequests::ConsultationRequest"
          resource.card = "decidim/consultation_requests/consultation_request"
          resource.searchable = true
        end
      end

      routes do
        scope "/admin" do
          resources :consultation_requests, controller: 'admin/consultation_requests', as: 'admin_consultation_requests' do
            resources :attachment_collections, controller: 'admin/attachment_collections', as: 'attachment_collections'
            resources :attachments, controller: 'admin/attachments', as: 'attachments'
          end
        end
        resources :consultation_requests, only: [:index, :show], as: 'consultation_requests'
      end

      initializer "decidim_consultation_requests.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::ConsultationRequests::Engine => "/"
        end
      end

      # decorators
      config.autoload_paths << File.join(
        Decidim::ConsultationRequests::Engine.root, "app", "decorators", "{**}"
      )

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::ConsultationRequests::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          require_dependency(c)
        end
      end

      # add cells views paths
      initializer "decidim_consultation_requests.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ConsultationRequests::Engine.root}/app/cells")
      end

      # initializer "decidim_consultation_requests.assets" do |app|
      #   app.config.assets.precompile += %w[decidim_consultation_requests_manifest.js decidim_consultation_requests_manifest.css]
      # end
    end
  end
end
