# This migration comes from decidim_expert_questions (originally 20210930101445)
class CreateDecidimExpertQuestionsExperts < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_expert_questions_experts do |t|
      t.references :decidim_user, null: false, foreign_key: true, index: true
      t.references :decidim_component, index: true, foreign_key: true

      t.string :avatar
      t.string :position
      t.string :affiliation
      t.string :description

      t.integer :weight, default: 0
      t.datetime :published_at

      t.timestamps
    end

    add_reference :decidim_expert_questions_user_questions, :decidim_expert_questions_experts, foreign_key: true, index: { name: "index_decidim_expert_on_decidim_user_question_id" }
  end
end
