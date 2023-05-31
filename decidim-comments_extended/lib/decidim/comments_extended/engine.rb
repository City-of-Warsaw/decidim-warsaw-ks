# frozen_string_literal: true

require 'rails'

module Decidim
  module CommentsExtended
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::CommentsExtended

      routes do
        resources :comments, only: [:edit, :update] do
          get :comment_id_via_token, on: :collection
          member do
            patch :full_update
          end
        end
      end

      initializer 'decidim_comments_extended.append_routes', after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::CommentsExtended::Engine => '/'
        end
      end

      # decorators
      config.autoload_paths << File.join(
        Decidim::CommentsExtended::Engine.root, 'app', 'decorators', '{**}'
      )

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::CommentsExtended::Engine.root + 'app/decorators/**/*_decorator*.rb').each do |c|
          require_dependency(c)
        end
      end

      # cells
      initializer 'decidim_comments_extended.add_cells_view_paths' do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::CommentsExtended::Engine.root}/app/cells")
      end
    end
  end
end
