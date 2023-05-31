class AddTokenToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_comments_comments, :token, :string
  end
end
