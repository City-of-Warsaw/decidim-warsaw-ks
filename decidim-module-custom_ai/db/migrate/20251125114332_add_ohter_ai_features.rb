class AddOhterAiFeatures < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_forms_answers, :ai_is_illogical, :boolean, default: false, null: false
    add_column :decidim_forms_answers, :ai_is_incomplete, :boolean, default: false, null: false
    add_column :decidim_forms_answers, :ai_is_vulgar, :boolean, default: false, null: false
  end
end
