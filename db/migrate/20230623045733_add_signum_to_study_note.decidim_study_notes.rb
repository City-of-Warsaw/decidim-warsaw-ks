# This migration comes from decidim_study_notes (originally 20230623045644)
class AddSignumToStudyNote < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_study_notes_study_notes, :signum_spr_id, :string
    add_column :decidim_study_notes_study_notes, :signum_nr_kancelaryjny, :string
    add_column :decidim_study_notes_study_notes, :signum_kor_id, :string
    add_column :decidim_study_notes_study_notes, :signum_znak_sprawy, :string
    add_column :decidim_study_notes_study_notes, :signum_registered_at, :datetime
    add_column :decidim_study_notes_study_notes, :signum_registered_by_user_id, :integer
  end
end
