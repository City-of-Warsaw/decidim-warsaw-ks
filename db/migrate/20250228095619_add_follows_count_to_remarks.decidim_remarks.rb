# This migration comes from decidim_remarks (originally 20250228095526)
class AddFollowsCountToRemarks < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_remarks_remarks, :follows_count, :integer, null: false, default: 0, index: true
  end
end
