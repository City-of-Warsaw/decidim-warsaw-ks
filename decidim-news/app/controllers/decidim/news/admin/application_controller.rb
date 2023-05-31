# frozen_string_literal: true

module Decidim
  module News
    module Admin
      class ApplicationController < Decidim::Admin::ApplicationController
        helper Decidim::ApplicationHelper
        helper_method :informations, :information

        layout "decidim/admin/news/informations"

        def informations
          @informations ||= Information.where(decidim_organization_id: current_organization.id).order(created_at: :desc).page(params[:page]).per(15)
        end

        def information
          @information ||= informations.find(params[:id]) if params[:id]
        end
      end
    end
  end
end
