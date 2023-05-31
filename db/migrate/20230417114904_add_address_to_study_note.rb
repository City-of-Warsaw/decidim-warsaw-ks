class AddAddressToStudyNote < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_study_notes_study_notes, :street, :string
    add_column :decidim_study_notes_study_notes, :street_number, :string
    add_column :decidim_study_notes_study_notes, :flat_number, :string
    add_column :decidim_study_notes_study_notes, :zip_code, :string
    add_column :decidim_study_notes_study_notes, :city, :string
  end
end
