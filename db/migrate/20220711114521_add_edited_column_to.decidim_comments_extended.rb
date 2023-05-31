# This migration comes from decidim_comments_extended (originally 20220711114402)
class AddEditedColumnTo < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_comments_comments, :edited, :boolean, default: false
  end
end
