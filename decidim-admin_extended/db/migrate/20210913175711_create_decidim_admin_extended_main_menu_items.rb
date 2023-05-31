class CreateDecidimAdminExtendedMainMenuItems < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_main_menu_items do |t|
      t.string :sys_name
      t.string :name
      t.integer :weight

      t.timestamps
    end
  end
end
