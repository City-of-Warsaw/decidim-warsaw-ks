# This migration comes from decidim_study_notes (originally 20230728160505)
class AddBarcodeToStudyNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_study_notes_study_notes, :signum_barcode, :string
  end
end
