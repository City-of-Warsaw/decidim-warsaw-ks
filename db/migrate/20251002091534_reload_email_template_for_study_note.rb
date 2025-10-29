class ReloadEmailTemplateForStudyNote < ActiveRecord::Migration[7.0]
  def change
    Decidim::AdminExtended::MailTemplatesGenerator.new.update_template(:create_study_note_confirmation)
    Decidim::AdminExtended::MailTemplatesGenerator.new.update_template(:create_study_note_confirmation_to_submitter)
  end
end
