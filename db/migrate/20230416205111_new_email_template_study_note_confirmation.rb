class NewEmailTemplateStudyNoteConfirmation < ActiveRecord::Migration[5.2]
  def change
    Decidim::AdminExtended::MailTemplatesGenerator.new.create_template(:create_study_note_confirmation)
  end
end
