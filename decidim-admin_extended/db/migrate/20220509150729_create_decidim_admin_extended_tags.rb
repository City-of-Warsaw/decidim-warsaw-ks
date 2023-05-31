class CreateDecidimAdminExtendedTags < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_tags do |t|
      t.string :name
      t.integer :organization_id

      t.timestamps
    end
  end
end
