class AddNewNotificationTemplateToStudyNoteZip < ActiveRecord::Migration[7.0]
  def change
    Decidim::AdminExtended::MailTemplatesGenerator.new.create_template(:study_note_zip_notification)
  end
end
