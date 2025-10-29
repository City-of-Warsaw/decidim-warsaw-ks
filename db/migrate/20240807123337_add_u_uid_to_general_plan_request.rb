class AddUUidToGeneralPlanRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_general_plan_requests_general_plan_requests, :uuid, :string
    add_index :decidim_general_plan_requests_general_plan_requests, :uuid, unique: true, name: "general_plan_requests_uuid"

    Decidim::GeneralPlanRequests::GeneralPlanRequest.all.each do |gpr|
      gpr.update(uuid: SecureRandom.hex(16))
    end
  end
end
