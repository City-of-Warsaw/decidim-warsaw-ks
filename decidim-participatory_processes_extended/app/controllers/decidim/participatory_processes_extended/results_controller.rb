# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    class ResultsController < Decidim::ParticipatoryProcessesExtended::ApplicationController
      include ParticipatorySpaceContext

      helper_method :collection, :current_participatory_space

      before_action :set_results_breadcrumb_item

      def index; end

      private

      def collection
        @collection ||= Decidim::ParticipatoryProcessesExtended::Result.where(participatory_space: current_participatory_space).published.sorted_by_weight
      end

      def current_participatory_space
        @current_participatory_space ||= ParticipatoryProcess.find_by(slug: params[:participatory_process_slug])
      end

      def set_results_breadcrumb_item
        context_breadcrumb_items << {
          label: I18n.t("results", scope: "decidim.admin.menu.participatory_processes_submenu"),
          active: true
        }
      end
    end
  end
end
