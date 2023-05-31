class AddEditedColumnTo < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_comments_comments, :edited, :boolean, default: false
  end
end
