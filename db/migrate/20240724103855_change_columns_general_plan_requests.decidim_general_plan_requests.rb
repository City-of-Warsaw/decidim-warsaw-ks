# This migration comes from decidim_general_plan_requests (originally 20240724103213)
class ChangeColumnsGeneralPlanRequests < ActiveRecord::Migration[5.2]
  def change
    change_column :decidim_general_plan_requests_general_plan_requests,
                  :request_body,
                  :text
    change_column :decidim_general_plan_requests_general_plan_requests,
                  :request_body_content_details,
                  :jsonb,
                  using: 'request_body_content_details::jsonb'
    change_column :decidim_general_plan_requests_general_plan_requests,
                  :details_land_parcels_with_parameters,
                  :jsonb,
                  using: 'details_land_parcels_with_parameters::jsonb'
  end
end

