class CreateDecidimAdminExtendedBannedWords < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_banned_words do |t|
      t.string :name
      
      t.timestamps
    end
  end
end
