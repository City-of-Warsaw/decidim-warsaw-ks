# This migration comes from decidim_ad_users_space (originally 20220531093700)
class CreateDecidimAdUsersSpaceInfoArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_ad_users_space_info_articles do |t|
      t.string :title
      t.text :body

      t.references :decidim_organization, foreign_key: true, index: { name: 'index_info_articles_on_decidim_organization_id' }
      t.timestamps
    end
  end
end
