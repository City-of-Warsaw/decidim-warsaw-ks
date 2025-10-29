# This migration comes from decidim_custom_proposals (originally 20230609093146)
class CreateDecidimCustomProposalsCustomProposals < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_custom_proposals_custom_proposals do |t|
      t.references :decidim_component, foreign_key: true, index: { name: 'index_dec_custom_proposals_custom_proposals_on_dec_component_id'}
      t.string :title
      t.string :body
      t.boolean :published
      t.integer :weight

      t.timestamps
    end
  end
end
