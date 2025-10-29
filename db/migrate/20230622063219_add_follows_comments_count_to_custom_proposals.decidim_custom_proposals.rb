# This migration comes from decidim_custom_proposals (originally 20230622062840)
class AddFollowsCommentsCountToCustomProposals < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_custom_proposals_custom_proposals, :follows_count, :integer, null: false, default: 0, index: true
    add_column :decidim_custom_proposals_custom_proposals, :comments_count, :integer, null: false, default: 0, index: true
  end
end
