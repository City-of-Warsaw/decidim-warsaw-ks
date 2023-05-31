class CreateDecidimAdminExtendedHeroSections < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_hero_sections do |t|
      t.string :title, null: false
      t.string :subtitle
      t.string :banner_img_alt
      t.string :system_name

      t.timestamps
    end
  end
end
