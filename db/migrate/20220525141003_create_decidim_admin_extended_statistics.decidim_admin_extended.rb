# This migration comes from decidim_admin_extended (originally 20220525134927)
class CreateDecidimAdminExtendedStatistics < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_statistics do |t|
      t.string :name
      t.string :sys_name
      t.integer :count, default: 0
      t.integer :weight, default: 0
      t.boolean :visibility, default: true

      t.timestamps
    end
  end
end
