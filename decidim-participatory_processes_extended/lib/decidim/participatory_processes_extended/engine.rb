module Decidim
  module ParticipatoryProcessesExtended
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ParticipatoryProcessesExtended

      component = Decidim.find_component_manifest('meetings')
      component.settings(:global) do |settings|
        settings.attribute :help_section_visibility, type: :boolean
        settings.attribute :help_section_title, type: :string
        settings.attribute :help_section_subtitle, type: :string
        settings.attribute :help_section_description, type: :text, editor: true
      end

      # custom - help section added to proposals component
      component_proposals = Decidim.find_component_manifest('proposals')
      component_proposals.settings(:global) do |settings|
        settings.attribute :help_section, type: :text, editor: true
      end

      routes do
        scope :admin, path: 'admin' do
          resources :main_page_processes, except: :show, controller: 'admin/main_page_processes'
          scope :participatory_processes do
            get '/:participatory_process_slug/reports', to: 'admin/participatory_process_report#index',as: :participatory_processes_reports_list
            get '/:participatory_process_slug/report', to: 'admin/participatory_process_report#new',as: :participatory_processes_reports_new
            patch '/:participatory_process_slug/report', to: 'admin/participatory_process_report#update',as: :participatory_processes_reports_list_update
            post '/:participatory_process_slug/report', to: 'admin/participatory_process_report#update',as: :participatory_processes_reports_list_new_save
            get '/:participatory_process_slug/report/edit', to: 'admin/participatory_process_report#edit',as: :participatory_processes_reports_list_edit
            post '/:participatory_process_slug/report/publish', to: 'admin/participatory_process_report#publish',as: :participatory_processes_reports_list_publish
            post '/:participatory_process_slug/report/unpublish', to: 'admin/participatory_process_report#unpublish',as: :participatory_processes_reports_list_unpublish
            post '/:participatory_process_slug/report/send_notification', to: 'admin/participatory_process_report#send_notification',as: :participatory_processes_reports_send_notification

            get '/:participatory_process_slug/report/file', to: 'admin/participatory_process_report_files#new',as: :participatory_processes_reports_list_new_file
            post '/:participatory_process_slug/report/file', to: 'admin/participatory_process_report_files#create',as: :participatory_processes_reports_list_new_file_save
            get '/:participatory_process_slug/report/file/:report_file_id', to: 'admin/participatory_process_report_files#edit',as: :participatory_processes_reports_list_edit_file
            patch '/:participatory_process_slug/report/file/:report_file_id', to: 'admin/participatory_process_report_files#update',as: :participatory_processes_reports_list_save_file
            delete '/:participatory_process_slug/report/file/:report_file_id', to: 'admin/participatory_process_report_files#delete',as: :participatory_processes_reports_list_delete_file

          end
        end
      end

      initializer "decidim_participatory_processes_extended.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::ParticipatoryProcessesExtended::Engine => "/"
        end

        Decidim::ParticipatoryProcesses::AdminEngine.routes.prepend do
          scope "/participatory_processes/:participatory_process_slug" do
            get '/attachments/multifile', to: 'participatory_process_attachments#multifiles',as: :participatory_processes_attachments_multifile
            post '/attachments/multifile', to: 'participatory_process_attachments#create_multifiles',as: :participatory_processes_attachments_create_multifiles
            get 'results' => '/decidim/participatory_processes_extended/admin/results#index', as: :results
            get 'results/new' => '/decidim/participatory_processes_extended/admin/results#new', as: :new_result
            post 'results' => '/decidim/participatory_processes_extended/admin/results#create', as: :create_result
            get 'results/:id/edit' => '/decidim/participatory_processes_extended/admin/results#edit', as: :edit_result
            patch 'results/:id' => '/decidim/participatory_processes_extended/admin/results#update', as: :update_result
            put 'results/:id' => '/decidim/participatory_processes_extended/admin/results#publish', as: :publish_result
            delete 'results/:id' => '/decidim/participatory_processes_extended/admin/results#destroy', as: :destroy_result
            post 'results/send_notification' => '/decidim/participatory_processes_extended/admin/results#send_notification', as: :send_notification_result
          end
        end

        Decidim::ParticipatoryProcessesExtended::Engine.routes.append do
          scope "/processes/:participatory_process_slug" do
            get 'results' => '/decidim/participatory_processes_extended/results#index', as: :participatory_process_results
            get 'participatory_process_reports' => '/decidim/participatory_processes_extended/participatory_process_reports#index', as: :participatory_process_reports
          end
        end
      end

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::ParticipatoryProcessesExtended::Engine.root + 'app/decorators/**/*_decorator*.rb').each do |c|
          load c
        end
      end

      initializer "decidim_participatory_processes_admin.menu" do
        Decidim.menu :admin_participatory_process_menu do |menu|
          menu.add_item :reports,
                        I18n.t("reports", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_participatory_processes_extended.participatory_processes_reports_list_path(current_participatory_space),
                        active: is_active_link?(decidim_participatory_processes_extended.participatory_processes_reports_list_path(current_participatory_space)),
                        icon_name: "direction-line",
                        if: allowed_to?(:index, :participatory_process_reports)
          menu.add_item :result,
                        I18n.t("results", scope: "decidim.admin.menu.participatory_processes_submenu"),
                        decidim_admin_participatory_processes.results_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.results_path(current_participatory_space)),
                        icon_name: "direction-line",
                        if: allowed_to?(:read, :result)
        end
      end

      # cells
      initializer 'decidim_participatory_processes_extended.add_cells_view_paths' do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ParticipatoryProcessesExtended::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ParticipatoryProcessesExtended::Engine.root}/app/views")
      end

      initializer "decidim_participatory_processes.admin_participatory_processes_menu" do
        Decidim.menu :admin_participatory_processes_menu do |menu|
          menu.add_item :main_page_processes,
                        I18n.t("sidebar_menu_nav.consultations_on_main_page", scope: "decidim.admin"),
                        decidim_participatory_processes_extended.main_page_processes_path,
                        position: 1,
                        if: allowed_to?(:manage, :main_page_processes),
                        active: is_active_link?(decidim_participatory_processes_extended.main_page_processes_path)
        end
      end

      # Initializer to:
      # - overwrite the default settings of content blocks
      # - add our content blocks for process
      initializer "decidim_participatory_processes_extended.content_blocks", after: :load_config_initializers do |_app|
        highlited_processes_cb = Decidim.content_blocks.for(:homepage).detect do |v|
          v.name == :highlighted_processes
        end
        highlited_processes_cb.settings.attributes[:max_results].default = 3

        participatory_process_hero_cb = Decidim.content_blocks.for(:participatory_process_homepage).detect do |v|
          v.name == :hero
        end

        participatory_process_hero_cb.settings do |settings|
          settings.attribute :button_text, type: :text, translated: true
          settings.attribute :button_url, type: :text, translated: true
          settings.attribute :image_alt, type: :text
        end

        Decidim.content_blocks.register(:participatory_process_homepage, :area_map) do |content_block|
          content_block.cell = "decidim/participatory_processes/content_blocks/area_map"
          content_block.public_name_key = "decidim.participatory_processes.content_blocks.area_map.name"
          content_block.default!
        end
      end
    end
  end
end
