class AddSequentialNumberToStudyNote < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_study_notes_study_notes, :sequential_number, :integer
  end
end
