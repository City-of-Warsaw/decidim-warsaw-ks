# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      class ParticipatoryProcessReportController < Admin::ApplicationController
        include Decidim::FormFactory
        layout 'decidim/admin/participatory_process'
        include Decidim::Admin::ParticipatorySpaceAdminContext

        helper_method :current_participatory_space

        add_breadcrumb_item_from_menu :admin_participatory_process_menu

        def index
          enforce_permission_to :index, :participatory_process_reports
        end

        def new
          enforce_permission_to :manage, :participatory_process_reports
          @form = form(Decidim::ParticipatoryProcessesExtended::Admin::ReportForm).instance
        end

        def edit
          enforce_permission_to :manage, :participatory_process_reports
          @form = form(Decidim::ParticipatoryProcessesExtended::Admin::ReportForm).from_model(current_participatory_space)
        end

        def update
          enforce_permission_to :update, :participatory_process_reports
          @form = form(Decidim::ParticipatoryProcessesExtended::Admin::ReportForm).from_params(params.merge(participatory_process: current_participatory_space))

          Decidim::ParticipatoryProcessesExtended::Admin::UpdateParticipatoryProcessReport.call(@form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t('participatory_process_report.update.success', scope: 'decidim.participatory_processes_extended.admin')
              redirect_to decidim_participatory_processes_extended.participatory_processes_reports_list_path(current_participatory_space)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t('participatory_process_report.update.error', scope: 'decidim.participatory_processes_extended.admin')
              render :edit
            end
          end
        end

        def publish
          enforce_permission_to :publish, :participatory_process_reports

          Decidim::ParticipatoryProcessesExtended::Admin::PublishParticipatoryProcessReport.call(current_participatory_space, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t('participatory_process_report.publish.success', scope: 'decidim.participatory_processes_extended.admin')
              redirect_to decidim_participatory_processes_extended.participatory_processes_reports_list_path(current_participatory_space)
            end

            on(:no_report_added) do
              flash.now[:alert] = I18n.t('participatory_process_report.publish.no_report_added', scope: 'decidim.participatory_processes_extended.admin')
              redirect_to decidim_participatory_processes_extended.participatory_processes_reports_list_path(current_participatory_space)
            end
          end
        end

        def unpublish
          enforce_permission_to :publish, :participatory_process_reports

          Decidim::ParticipatoryProcessesExtended::Admin::UnpublishParticipatoryProcessReport.call(current_participatory_space, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t('participatory_process_report.unpublish.success', scope: 'decidim.participatory_processes_extended.admin')
              redirect_to decidim_participatory_processes_extended.participatory_processes_reports_list_path(current_participatory_space)
            end
          end
        end

        def send_notification
          enforce_permission_to :send_notification, :participatory_process_reports

          Decidim::ParticipatoryProcessesExtended::Admin::SendNotificationForParticipatoryProcessReport.call(current_participatory_space, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t('participatory_process_report.send_notification.success', scope: 'decidim.participatory_processes_extended.admin')
            end

            on(:invalid) do
              flash[:notice] = I18n.t('participatory_process_report.send_notification.error', scope: 'decidim.participatory_processes_extended.admin')
            end

            on(:no_report_added) do
              flash.now[:alert] = I18n.t('participatory_process_report.send_notification.no_report_added', scope: 'decidim.participatory_processes_extended.admin')
            end

            on(:report_notification_was_send) do
              flash.now[:alert] = I18n.t('participatory_process_report.send_notification.report_notification_was_send', scope: 'decidim.participatory_processes_extended.admin')
            end

            redirect_to decidim_participatory_processes_extended.participatory_processes_reports_list_path(current_participatory_space)
          end
        end

        private

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::ParticipatoryProcesses::Admin::ApplicationController)
        end

        def organization_participatory_processes
          @organization_participatory_processes ||= Decidim::ParticipatoryProcesses::OrganizationParticipatoryProcesses.new(current_organization).query
        end

        def current_participatory_space
          return unless params['participatory_process_slug']

          @current_participatory_space ||= organization_participatory_processes.where(slug: params['participatory_process_slug']).or(
            organization_participatory_processes.where(id: params['participatory_process_slug'])
          ).first!
        end
      end
    end
  end
end
