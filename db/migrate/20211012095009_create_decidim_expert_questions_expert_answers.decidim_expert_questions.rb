# This migration comes from decidim_expert_questions (originally 20211012094254)
class CreateDecidimExpertQuestionsExpertAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_expert_questions_expert_answers do |t|
      t.references :decidim_expert, null: false, foreign_key: { to_table: :decidim_expert_questions_experts }, index: { name: 'index_decidim_expert_on_expert_answer' }
      t.references :decidim_user_question, null: false, foreign_key: { to_table: :decidim_expert_questions_user_questions }, index: { name: 'index_decidim_user_question_on_expert_answer' }

      t.text :body
      t.datetime :published_at

      t.timestamps
    end

    add_column :decidim_expert_questions_user_questions, :comments_count, :integer, null: false, default: 0, index: true
  end
end
