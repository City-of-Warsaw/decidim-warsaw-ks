class AddGroupingFieldsToAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_forms_answers, :incorrect_group_id, :integer
    add_column :decidim_forms_answers, :similar_group_id, :integer
  end
end
