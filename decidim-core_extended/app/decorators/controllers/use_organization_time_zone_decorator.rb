# frozen_string_literal: true

require "active_support/concern"

Decidim::UseOrganizationTimeZone.class_eval do
  # overwritten method
  # in env: test & production, there are objects that return nil with organization_id
  # return fixed time zone, for: use_organization_time_zone
  def organization_time_zone
    if current_organization
      @organization_time_zone ||= current_organization.time_zone
    else
      "Warsaw"
    end
  end
end
