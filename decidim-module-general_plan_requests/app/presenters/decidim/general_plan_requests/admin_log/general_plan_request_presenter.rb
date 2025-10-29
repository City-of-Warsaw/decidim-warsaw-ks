# frozen_string_literal: true

module Decidim
  module GeneralPlanRequests
    module AdminLog
      # This class holds the logic to present a `Decidim::GeneralPlanRequests::GeneralPlanRequest`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    GeneralPlanRequestPresenter.new(action_log, view_helpers).present
      class GeneralPlanRequestPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "export_general_plan_requests"
            "decidim.admin_log.general_plan_request.#{action}"
          else
            super
          end
        end
      end
    end
  end
end
