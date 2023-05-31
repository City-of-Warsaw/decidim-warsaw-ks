module Decidim
  module ParticipatoryProcessesExtended
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ParticipatoryProcessesExtended

      component = Decidim.find_component_manifest('meetings')
      component.settings(:global) do |settings|
        settings.attribute :help_section, type: :text, translated: true, editor: true
      end

      # custom - help section added to proposals component
      component_proposals = Decidim.find_component_manifest('proposals')
      component_proposals.settings(:global) do |settings|
        settings.attribute :help_section, type: :text, editor: true
      end

      routes do
        scope :admin, path: 'admin' do 
          resources :main_page_processes, except: :show, controller: 'admin/main_page_processes'
        end
      end

      initializer "decidim_participatory_processes_extended.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::ParticipatoryProcessesExtended::Engine => "/"
        end
      end

      # decorators
      config.autoload_paths << File.join(
        Decidim::ParticipatoryProcessesExtended::Engine.root, 'app', 'decorators', '{**}'
      )

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::ParticipatoryProcessesExtended::Engine.root + 'app/decorators/**/*_decorator*.rb').each do |c|
          require_dependency(c)
        end
      end

      # cells
      initializer 'decidim_participatory_processes_extended.add_cells_view_paths' do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ParticipatoryProcessesExtended::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ParticipatoryProcessesExtended::Engine.root}/app/views")
      end

      initializer "decidim_participatory_processes.admin_participatory_processes_menu" do
        Decidim.menu :admin_participatory_processes_menu do |menu|
          menu.item I18n.t("sidebar_menu_nav.consultations_on_main_page", scope: "decidim.admin"),
                    decidim_participatory_processes_extended.main_page_processes_path,
                    position: 1,
                    if: allowed_to?(:manage, :main_page_processes),
                    active: is_active_link?(decidim_participatory_processes_extended.main_page_processes_path)
        end
      end

      # Initializer to overwrite the default settings of content blocks
      initializer "decidim_participatory_processes_extended.content_blocks", after: :load_config_initializers do |_app|
        highlited_processes_cb = Decidim.content_blocks.for(:homepage).detect do |v|
          v.name == :highlighted_processes
        end
        highlited_processes_cb.settings.attributes[:max_results].default = 3
      end
    end
  end
end
