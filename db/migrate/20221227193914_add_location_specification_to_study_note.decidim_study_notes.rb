# This migration comes from decidim_study_notes (originally 20221227193530)
class AddLocationSpecificationToStudyNote < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_study_notes_study_notes, :location_specification, :string
  end
end
