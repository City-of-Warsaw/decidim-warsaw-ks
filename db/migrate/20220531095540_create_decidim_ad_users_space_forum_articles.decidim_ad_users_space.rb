# This migration comes from decidim_ad_users_space (originally 20220531093633)
class CreateDecidimAdUsersSpaceForumArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_ad_users_space_forum_articles do |t|
      t.string :title
      t.text :body
      t.integer :comments_count, null: false, default: 0, index: true

      t.references :decidim_organization, foreign_key: true, index: { name: 'index_forum_articles_on_decidim_organization_id' }
      t.timestamps
    end
  end
end
