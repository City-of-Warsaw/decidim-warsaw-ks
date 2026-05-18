# frozen_string_literal: true

class CreateDecidimCustomAiAnswerVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_custom_ai_answer_versions do |t|
      t.references :decidim_user, foreign_key: { to_table: :decidim_users }, index: true
      t.references :answer, null: false, foreign_key: { to_table: :decidim_forms_answers }, index: true

      t.text :ai_decision_body
      t.integer :ai_decision_status
      t.integer :status

      t.timestamps
    end
  end
end
