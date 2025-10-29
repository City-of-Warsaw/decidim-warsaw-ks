class AddMissingTemplateToSubmitterConfirmation < ActiveRecord::Migration[7.0]
  def change
    Decidim::AdminExtended::MailTemplatesGenerator.new.create_template(
      :create_study_note_confirmation_to_submitter
    )
  end
end
