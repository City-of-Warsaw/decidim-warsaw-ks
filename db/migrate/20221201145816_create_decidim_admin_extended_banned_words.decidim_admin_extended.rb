# This migration comes from decidim_admin_extended (originally 20221201145629)
class CreateDecidimAdminExtendedBannedWords < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_admin_extended_banned_words do |t|
      t.string :name
      
      t.timestamps
    end
  end
end
