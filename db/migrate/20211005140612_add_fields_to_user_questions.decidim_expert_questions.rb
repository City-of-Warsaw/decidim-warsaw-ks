# This migration comes from decidim_expert_questions (originally 20211005140406)
class AddFieldsToUserQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_expert_questions_user_questions, :decidim_author_type, :string
    add_column :decidim_expert_questions_user_questions, :signature, :string
    add_column :decidim_expert_questions_user_questions, :email, :string
    add_column :decidim_expert_questions_user_questions, :district, :string
    add_column :decidim_expert_questions_user_questions, :age, :string
    add_column :decidim_expert_questions_user_questions, :gender, :string
  end
end
