# frozen_string_literal: true

require_dependency 'decidim/admin_extended/application_controller'

module Decidim
  module AdminExtended
    class StatisticsController < ApplicationController
      layout 'decidim/admin/settings'

      helper_method :statistic, :statistics

      def index
        enforce_permission_to :update, :organization, organization: current_organization

        generate_menu_items # TODO: do usuniecia gdy sie wszystkie wygeneruja
        Decidim::AdminExtended::Statistic.update_counts
        statistics
      end

      def edit
        enforce_permission_to :update, :organization, organization: current_organization
        @form = form(Decidim::AdminExtended::StatisticForm).from_model(statistic)
      end

      def update
        enforce_permission_to :update, :organization, organization: current_organization
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

      private

      def statistic
        @statistic ||= Decidim::AdminExtended::Statistic.find(params[:id])
      end

      def statistics
        @statistics ||= Decidim::AdminExtended::Statistic.all
      end

      def generate_menu_items
        return if manageable_stats.size <= statistics.count

        manageable_stats.each do |m|
          unless Decidim::AdminExtended::Statistic.find_by(sys_name: m)
            Decidim::AdminExtended::Statistic.create(
              name: t(m, scope: 'decidim.admin_extended.statistics.default_name'),
              sys_name: m
            )
          end
        end
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
