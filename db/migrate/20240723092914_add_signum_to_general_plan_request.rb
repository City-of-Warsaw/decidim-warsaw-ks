class AddSignumToGeneralPlanRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_general_plan_requests_general_plan_requests, :signum_spr_id, :string
    add_column :decidim_general_plan_requests_general_plan_requests, :signum_nr_kancelaryjny, :string
    add_column :decidim_general_plan_requests_general_plan_requests, :signum_kor_id, :string
    add_column :decidim_general_plan_requests_general_plan_requests, :signum_znak_sprawy, :string
    add_column :decidim_general_plan_requests_general_plan_requests, :signum_registered_at, :datetime
    add_column :decidim_general_plan_requests_general_plan_requests, :signum_registered_by_user_id, :integer
  end
end
