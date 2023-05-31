class CreateDecidimAdminExtendedDepartments < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_departments do |t|
      t.string :name
      t.integer :organization_id

      t.timestamps
    end
  end
end
