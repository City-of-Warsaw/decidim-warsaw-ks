# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # Controller that allows managing all Main Page Processes (processes appearing on home page) at the admin panel.
      class MainPageProcessesController < Admin::ApplicationController
        include Decidim::FormFactory
      
        helper_method :main_page_processes
      
        def index
          enforce_permission_to :manage, :main_page_processes
        end
      
        def new
          enforce_permission_to :manage, :main_page_processes
          @form = form(Decidim::ParticipatoryProcessesExtended::Admin::MainPageProcessForm).instance
        end
      
        def create
          enforce_permission_to :manage, :main_page_processes
          @form = form(Decidim::ParticipatoryProcessesExtended::Admin::MainPageProcessForm).from_params(params)
          @main_page_process = Decidim::ParticipatoryProcess.find_by(id: params[:main_page_process][:process_id])
        
          Decidim::ParticipatoryProcessesExtended::Admin::UpdateMainPageProcess.call(@main_page_process, @form, current_user, :add_process_to_main_page) do
            on(:ok) do
              flash[:notice] = I18n.t("main_page_processes.create.success", scope: "decidim.participatory_processes_extended")
              redirect_to decidim_participatory_processes_extended.main_page_processes_path
            end
          
            on(:invalid) do
              flash.now[:alert] = I18n.t("main_page_processes.create.error", scope: "decidim.participatory_processes_extended")
              render :new
            end
          end
        end
      
        def edit
          enforce_permission_to :manage, :main_page_processes
          @form = form(Decidim::ParticipatoryProcessesExtended::Admin::MainPageProcessForm).from_model(main_page_process)
        end
      
        def update
          enforce_permission_to :manage, :main_page_processes
          @form = form(Decidim::ParticipatoryProcessesExtended::Admin::MainPageProcessForm).from_params(params.merge(process: main_page_process))
        
          Decidim::ParticipatoryProcessesExtended::Admin::UpdateMainPageProcess.call(main_page_process, @form, current_user, :update_main_page_process) do
            on(:ok) do
              flash[:notice] = I18n.t("main_page_processes.update.success", scope: "decidim.participatory_processes_extended")
              redirect_to decidim_participatory_processes_extended.main_page_processes_path
            end
          
            on(:invalid) do
              flash.now[:alert] = I18n.t("main_page_processes.update.error", scope: "decidim.participatory_processes_extended")
              render :edit
            end
          end
        end
      
        def destroy
          enforce_permission_to :manage, :main_page_processes
          Decidim::ParticipatoryProcessesExtended::Admin::DestroyMainPageProcess.call(main_page_process, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("main_page_processes.destroy.success", scope: "decidim.participatory_processes_extended")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("main_page_processes.destroy.error", scope: "decidim.participatory_processes_extended")
            end
          end
          redirect_to decidim_participatory_processes_extended.main_page_processes_path
        end
      
        private
      
        def main_page_processes
          Decidim::ParticipatoryProcess.on_main_page.order_for_main_page
        end
      
        def main_page_process
          @main_page_process ||= Decidim::ParticipatoryProcess.find_by(id: params[:id])
        end
      end
    end
  end
end
