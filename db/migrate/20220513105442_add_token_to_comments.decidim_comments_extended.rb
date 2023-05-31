# This migration comes from decidim_comments_extended (originally 20220513102133)
class AddTokenToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_comments_comments, :token, :string
  end
end
