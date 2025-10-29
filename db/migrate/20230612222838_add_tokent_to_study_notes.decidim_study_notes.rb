# This migration comes from decidim_study_notes (originally 20230612222507)
class AddTokentToStudyNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_study_notes_study_notes, :token, :string

    reversible do |direction|
      direction.up do
        Decidim::StudyNotes::StudyNote.all.each do |note|
          note.update_column(:token, SecureRandom.hex(16))
        end
      end
    end
  end
end
