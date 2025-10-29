# frozen_string_literal: true

module Decidim
  module AdminExtended
    class StatisticsController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Officializations::Filterable

      helper_method :statistic

      layout 'decidim/admin/settings'

      add_breadcrumb_item_from_menu :admin_settings_menu

      def index
        enforce_permission_to :update, :organization, organization: current_organization
        @statistics = filtered_collection
      end

      # used for the archive
      def show; end

      def new
        enforce_permission_to :new, :statistics
        @form = form(Decidim::AdminExtended::StatisticForm).instance
      end

      def edit
        enforce_permission_to :update, :statistics, statistic: statistic
        @form = form(Decidim::AdminExtended::StatisticForm).from_model(statistic)
      end

      def create
        enforce_permission_to :new, :statistics
        form = form(Decidim::AdminExtended::StatisticForm).from_params(params)

        Decidim::AdminExtended::CreateStatistic.call(form) do
          on(:ok) do
            flash[:notice] = I18n.t('statistics.create.success', scope: 'decidim.admin_extended')
            redirect_to decidim_admin_extended.statistics_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t('statistics.create.error', scope: 'decidim.admin_extended')
            render :edit
          end
        end
      end

      def update
        enforce_permission_to :update, :statistics, organization: statistic
        @form = form(Decidim::AdminExtended::StatisticForm).from_params(params)

        Decidim::AdminExtended::UpdateStatistic.call(statistic, @form) do
          on(:ok) do
            flash[:notice] = I18n.t('statistics.update.success', scope: 'decidim.admin_extended')
            redirect_to decidim_admin_extended.statistics_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t('statistics.update.error', scope: 'decidim.admin_extended')
            render :edit
          end
        end
      end

      def destroy
        enforce_permission_to :delete, :statistics, statistic: statistic

        Decidim::AdminExtended::DestroyStatistic.call(statistic, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t('statistics.destroy.success', scope: 'decidim.admin_extended')
            redirect_to decidim_admin_extended.statistics_path
          end

          on(:not_allowed) do
            flash[:alert] = I18n.t('statistics.destroy.not_allowed', scope: 'decidim.admin_extended')
            redirect_to decidim_admin_extended.statistics_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t('statistics.destroy.error', scope: 'decidim.admin_extended')
            redirect_to decidim_admin_extended.statistics_path
          end
        end
      end

      private

      def statistic
        @statistic ||= Decidim::AdminExtended::Statistic.find(params[:id])
      end

      def collection
        # For Client's request - not present all data
        @collection ||= Decidim::AdminExtended::Statistic.excluding_hidden_stats
      end

      # Private method: returns Array of registered stats names and custom stats names
      #
      # returns: Array
      def manageable_stats
        @manageable_stats ||= Decidim::AdminExtended::Statistic.manageable_stats
      end
    end
  end
end
