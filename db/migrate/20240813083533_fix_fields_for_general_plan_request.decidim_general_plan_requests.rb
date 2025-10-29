# This migration comes from decidim_general_plan_requests (originally 20240813081451)
class FixFieldsForGeneralPlanRequest < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_general_plan_requests_general_plan_requests,
                  :submitter_data_ePUAP_box_address_or_electronic_delivery_address,
                  :submitter_data_epuap_delivery_address

    rename_column :decidim_general_plan_requests_general_plan_requests,
                  :attorney_data_ePUAP_box_address_or_electronic_delivery_address,
                  :attorney_data_epuap_delivery_address

    remove_column :decidim_general_plan_requests_general_plan_requests,
                  :perpetual_owner_of_the_property

    add_column :decidim_general_plan_requests_general_plan_requests,
               :perpetual_owner_of_the_property,
               :boolean
  end
end
