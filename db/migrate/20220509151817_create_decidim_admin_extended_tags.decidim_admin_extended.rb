# This migration comes from decidim_admin_extended (originally 20220509150729)
class CreateDecidimAdminExtendedTags < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_tags do |t|
      t.string :name
      t.integer :organization_id

      t.timestamps
    end
  end
end
