class AddTokenToUserQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_expert_questions_user_questions, :token, :string
  end
end
