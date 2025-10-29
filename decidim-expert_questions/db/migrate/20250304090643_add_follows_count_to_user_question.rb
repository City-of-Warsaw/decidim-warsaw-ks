class AddFollowsCountToUserQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_expert_questions_user_questions, :follows_count, :integer, null: false, default: 0, index: true
  end
end
