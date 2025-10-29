class AddDecidimRemarkVote < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_remarks_remark_votes do |t|
      t.integer :weight, null: false
      t.references :decidim_remarks_remark, null: false, index: { name: "decidim_remarks_remark_vote_comment" }
      t.references :decidim_user, null: false, index: { name: "decidim_remarks_remark_vote_author" }

      t.timestamps
    end

    add_index :decidim_remarks_remark_votes, [:decidim_remarks_remark_id, :decidim_user_id], unique: true, name: "decidim_remarks_remark_vote_user_unique"
  end
end
