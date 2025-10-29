# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    class ParticipatoryProcessReportsController < Decidim::ParticipatoryProcessesExtended::ApplicationController
      include ParticipatorySpaceContext

      helper_method :current_participatory_space

      before_action :set_process_report_breadcrumb_item

      def index; end

      private

      def current_participatory_space
        @current_participatory_space ||= ParticipatoryProcess.find_by(slug: params[:participatory_process_slug])
      end

      def set_process_report_breadcrumb_item
        context_breadcrumb_items << {
          label: I18n.t("reports", scope: "decidim.admin.menu.participatory_processes_submenu"),
          active: true
        }
      end
    end
  end
end
