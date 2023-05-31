class CreateDecidimExpertQuestionsUserQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_expert_questions_user_questions do |t|
      t.text :body, null: false
      t.string :status, default: 'new'
      t.references :decidim_author, null: false, index: { name: "decidim_expert_user_question_author" }

      t.timestamps
    end
  end
end
