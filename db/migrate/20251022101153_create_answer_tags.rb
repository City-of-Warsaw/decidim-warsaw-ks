class CreateAnswerTags < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_custom_ai_answer_tags do |t|
      t.references :decidim_custom_ai_tags, index: { name: "decidim_custom_ai_answer_tags_tags_ids"}
      t.references :decidim_forms_answers, index: { name: "decidim_custom_ai_answer_tags_answers_ids"}
      t.timestamps
    end
  end
end
