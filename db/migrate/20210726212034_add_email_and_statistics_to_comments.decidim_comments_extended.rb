# This migration comes from decidim_comments_extended (originally 20210726211838)
class AddEmailAndStatisticsToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_comments_comments, :gender, :string
    add_column :decidim_comments_comments, :age, :string
    add_column :decidim_comments_comments, :district, :string
  end
end
