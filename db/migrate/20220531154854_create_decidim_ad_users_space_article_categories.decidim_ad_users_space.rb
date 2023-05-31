# This migration comes from decidim_ad_users_space (originally 20220531154205)
class CreateDecidimAdUsersSpaceArticleCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_ad_users_space_article_categories do |t|
      t.string :name
      t.string :description

      t.references :decidim_organization, foreign_key: true, index: { name: 'index_article_categories_on_organization_id' }
      t.timestamps
    end

    add_column :decidim_ad_users_space_info_articles, :article_category_id, :integer
  end
end
