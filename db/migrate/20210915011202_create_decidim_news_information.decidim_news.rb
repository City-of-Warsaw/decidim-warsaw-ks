# This migration comes from decidim_news (originally 20210915003354)
class CreateDecidimNewsInformation < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_news_information do |t|
      t.string :title, mull: false
      t.text :body, mull: false

      t.references :decidim_organization, foreign_key: true

      t.timestamps
    end
  end
end
