# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      class ParticipatoryProcessReportFilesController < Admin::ApplicationController
        include Decidim::FormFactory
        layout 'decidim/admin/participatory_process'
        include Decidim::Admin::ParticipatorySpaceAdminContext

        helper_method :current_participatory_space, :report_file

        before_action :set_reports_breadcrumb_item

        def new
          enforce_permission_to :manage, :participatory_process_reports
          @form = form(Decidim::ParticipatoryProcessesExtended::Admin::ReportFileForm).instance
        end

        def create
          enforce_permission_to :create_file, :participatory_process_reports
          @form = form(Decidim::ParticipatoryProcessesExtended::Admin::ReportFileForm).from_params(params)

          Decidim::ParticipatoryProcessesExtended::Admin::CreateParticipatoryProcessReportFile.call(@form, current_user, current_participatory_space) do
            on(:ok) do
              flash[:notice] = I18n.t('participatory_process_report_files.create.success', scope: 'decidim.participatory_processes_extended.admin')
              redirect_to decidim_participatory_processes_extended.participatory_processes_reports_list_path(current_participatory_space)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t('participatory_process_report_files.create.error', scope: 'decidim.participatory_processes_extended.admin')
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :edit_file, :participatory_process_reports
          @form = form(Decidim::ParticipatoryProcessesExtended::Admin::ReportFileForm).from_model(report_file)
        end

        def update
          enforce_permission_to :update_file, :participatory_process_reports
          @form = form(Decidim::ParticipatoryProcessesExtended::Admin::ReportFileForm).from_params(params.merge(reported_file: report_file))

          Decidim::ParticipatoryProcessesExtended::Admin::UpdateParticipatoryProcessReportFile.call(@form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t('participatory_process_report_files.update.success', scope: 'decidim.participatory_processes_extended.admin')
              redirect_to decidim_participatory_processes_extended.participatory_processes_reports_list_path(current_participatory_space)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t('participatory_process_report_files.update.error', scope: 'decidim.participatory_processes_extended.admin')
              render :edit
            end
          end
        end

        def delete
          enforce_permission_to :delete_file, :participatory_process_reports
          Decidim::ParticipatoryProcessesExtended::Admin::DestroyParticipatoryProcessReportFile.call(report_file, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t('participatory_process_report_files.delete_file.success', scope: 'decidim.participatory_processes_extended.admin')
              redirect_to decidim_participatory_processes_extended.participatory_processes_reports_list_path(current_participatory_space)
            end
          end
        end

        private

        def organization_participatory_processes
          @organization_participatory_processes ||= Decidim::ParticipatoryProcesses::OrganizationParticipatoryProcesses.new(current_organization).query
        end

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::ParticipatoryProcesses::Admin::ApplicationController)
        end

        def report_file
          current_participatory_space.participatory_process_report_files.find(params[:report_file_id])
        end

        def current_participatory_space
          return unless params['participatory_process_slug']

          @current_participatory_space ||= organization_participatory_processes.where(slug: params['participatory_process_slug']).or(
            organization_participatory_processes.where(id: params['participatory_process_slug'])
          ).first!
        end

        def set_reports_breadcrumb_item
          controller_breadcrumb_items << {
            label: I18n.t("reports", scope: "decidim.admin.menu.participatory_processes_submenu"),
            url: decidim_participatory_processes_extended.participatory_processes_reports_list_path(current_participatory_space),
            active: true
          }
        end
      end
    end
  end
end
