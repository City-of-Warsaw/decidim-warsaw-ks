# frozen_string_literal: true

require "decidim/general_plan_requests/admin"
require "decidim/general_plan_requests/engine"
require "decidim/general_plan_requests/admin_engine"
require "decidim/general_plan_requests/component"

module Decidim
  # This namespace holds the logic of the `GeneralPlanRequests` component. This component
  # allows users to create general_plan_requests in a participatory space.
  module GeneralPlanRequests
    autoload :GeneralPlanRequestSerializer, "decidim/general_plan_requests/general_plan_request_serializer"
  end
end
