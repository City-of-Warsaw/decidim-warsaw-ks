# This migration comes from decidim_comments_extended (originally 20210803094125)
class AddMoreFieldsToCommentForUnregisteredUser < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_comments_comments, :email, :string
    add_column :decidim_comments_comments, :signature, :string
  end
end
