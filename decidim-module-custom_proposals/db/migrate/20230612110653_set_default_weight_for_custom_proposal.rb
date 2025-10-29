class SetDefaultWeightForCustomProposal < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_custom_proposals_custom_proposals, :weight, 0
  end
end
