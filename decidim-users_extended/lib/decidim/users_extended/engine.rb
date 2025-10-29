# frozen_string_literal: true

module Decidim
  module UsersExtended
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::UsersExtended

      routes do
        # scope '/admin' do
        get 'login-by-warszawa19115',       controller: 'sessions', action: 'peum_login', as: :peum_login
        get 'auth/warszawa19115/callback',  controller: 'sessions', action: 'peum_callback'
        get 'adlogin',  controller: 'sessions', action: 'new'
        get 'sign-in',  controller: 'sessions', action: 'new'
        post 'adlogin', controller: 'sessions', action: 'create'
        # end
        get 'check-nickname', controller: 'registrations', action: 'check_nickname'
      end

      initializer "decidim_users_extended.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::UsersExtended::Engine => "/"
        end
      end

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::UsersExtended::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          load c
        end
      end

      # make cells available to applications that use this Engine
      initializer "decidim_users_extended.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::UsersExtended::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::UsersExtended::Engine.root}/app/views")
      end
    end
  end
end
