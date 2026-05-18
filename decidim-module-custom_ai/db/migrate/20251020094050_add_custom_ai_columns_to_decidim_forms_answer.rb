class AddCustomAiColumnsToDecidimFormsAnswer < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_forms_answers, :ai_decision_status, :integer
    add_column :decidim_forms_answers, :status, :integer
    add_column :decidim_forms_answers, :ai_decision_body, :string
    add_column :decidim_forms_answers, :ai_suggestion_body, :string
    add_column :decidim_forms_answers, :ai_is_complicated, :boolean, default: false, null: false
  end
end
