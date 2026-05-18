class AddConfirmationSendToStudyNotes < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_study_notes_study_notes, :submitter_confirmation_send, :boolean, default: false
  end
end
