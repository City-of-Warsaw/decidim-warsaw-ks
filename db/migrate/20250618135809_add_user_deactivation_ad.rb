class AddUserDeactivationAd < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_users,:ad_access_deactivate_date,:datetime
  end
end
