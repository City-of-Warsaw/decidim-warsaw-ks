# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # Controller that allows managing all Results (cosuntlation effects appearing on process page) at the admin panel
      class ResultsController < Decidim::Admin::ApplicationController
        include Decidim::Admin::ParticipatorySpaceAdminContext
        include Decidim::ParticipatoryProcesses::Admin::Concerns::ParticipatoryProcessAdmin
        include Decidim::Paginable
        include Decidim::Admin::Filterable
        participatory_space_admin_layout

        helper_method :collection, :result, :notification_can_be_sent?

        def index
          enforce_permission_to :read, :result
        end

        def new
          enforce_permission_to :create, :result
          @form = form(Decidim::ParticipatoryProcessesExtended::Admin::ResultForm).instance
        end

        def create
          enforce_permission_to :create, :result
          @form = form(Decidim::ParticipatoryProcessesExtended::Admin::ResultForm).from_params(params)

          Decidim::ParticipatoryProcessesExtended::Admin::CreateResult.call(@form, current_participatory_space, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t('results.create.success', scope: 'decidim.participatory_processes_extended.admin')
              redirect_to decidim_admin_participatory_processes.results_path(current_participatory_space)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t('results.create.error', scope: 'decidim.participatory_processes_extended.admin')
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :result, result: result
          @form = form(Decidim::ParticipatoryProcessesExtended::Admin::ResultForm).from_model(result)
        end

        def update
          enforce_permission_to :update, :result, result: result
          @form = form(Decidim::ParticipatoryProcessesExtended::Admin::ResultForm).from_params(params)

          Decidim::ParticipatoryProcessesExtended::Admin::UpdateResult.call(@form, result, current_user, current_participatory_space) do
            on(:ok) do
              flash[:notice] = I18n.t('results.update.success', scope: 'decidim.participatory_processes_extended.admin')
              redirect_to decidim_admin_participatory_processes.results_path(current_participatory_space)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t('results.update.error', scope: 'decidim.participatory_processes_extended.admin')
              render :edit
            end
          end
        end

        def publish
          enforce_permission_to :publish, :result

          Decidim::ParticipatoryProcessesExtended::Admin::PublishResult.call(result, current_user, current_participatory_space) do
            on(:ok) do
              flash[:notice] = I18n.t('results.publish.success', scope: 'decidim.participatory_processes_extended.admin')
              redirect_to decidim_admin_participatory_processes.results_path(current_participatory_space)
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :result, result: result
          result.destroy!
          revert_consultation_status

          flash[:notice] = I18n.t('results.destroy.success', scope: 'decidim.participatory_processes_extended.admin')
          redirect_to decidim_admin_participatory_processes.results_path(current_participatory_space)
        end

        def send_notification
          enforce_permission_to :send_notification, :result

          Decidim::ParticipatoryProcessesExtended::Admin::SendNotificationForResult.call(current_participatory_space, current_user, collection) do
            on(:ok) do
              flash[:notice] = I18n.t('results.send_notification.success', scope: 'decidim.participatory_processes_extended.admin')
              redirect_to decidim_admin_participatory_processes.results_path(current_participatory_space)
            end

            on(:no_report_added) do
              flash.now[:alert] = I18n.t('results.send_notification.no_result_added', scope: 'decidim.participatory_processes_extended.admin')
              redirect_to decidim_admin_participatory_processes.results_path(current_participatory_space)
            end

            on(:report_notification_was_send) do
              flash.now[:alert] = I18n.t('results.send_notification.result_notification_was_send', scope: 'decidim.participatory_processes_extended.admin')
              redirect_to decidim_admin_participatory_processes.results_path(current_participatory_space)
            end
          end
        end

        private

        def result
          @result ||= collection.find(params[:id])
        end

        def collection
          @collection ||= Decidim::ParticipatoryProcessesExtended::Result.where(participatory_space: current_participatory_space).sorted_by_weight.page(params[:page]).per(15)
        end

        # private method
        # After delete all collection belongs to current participatory space,
        # change consultation status back to 'Opublikowano raport' for process of this space
        # returns Boolean
        def revert_consultation_status
          current_participatory_space.update(consultation_status: 'report') unless collection.any?
        end

        # private method
        # use in index view to enable/disable button 'send_notification'
        # returns Boolean
        def notification_can_be_sent?
          collection.any? &&
            collection.exists?(notification_send: false, published: true) &&
            current_participatory_space.consultation_status == 'effects'
        end
      end
    end
  end
end
