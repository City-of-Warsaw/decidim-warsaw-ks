class MakePublishedDefaultFalseForCustomProposals < ActiveRecord::Migration[5.2]
  def change
    change_column_default :decidim_custom_proposals_custom_proposals, :published, false

    Decidim::CustomProposals::CustomProposal.where(published: nil).update_all(published: false)
  end
end
