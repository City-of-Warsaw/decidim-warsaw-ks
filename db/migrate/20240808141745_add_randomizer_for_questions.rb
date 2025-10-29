class AddRandomizerForQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_forms_questions,:random_order,:boolean, :default => false
  end
end
