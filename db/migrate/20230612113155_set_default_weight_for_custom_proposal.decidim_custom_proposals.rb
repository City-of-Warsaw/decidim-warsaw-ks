# This migration comes from decidim_custom_proposals (originally 20230612110653)
class SetDefaultWeightForCustomProposal < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_custom_proposals_custom_proposals, :weight, 0
  end
end
