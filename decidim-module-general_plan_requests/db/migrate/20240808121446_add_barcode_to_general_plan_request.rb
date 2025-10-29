class AddBarcodeToGeneralPlanRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_general_plan_requests_general_plan_requests, :signum_barcode, :string
  end
end
