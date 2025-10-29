class AddAnswerQuestionnaireConfirmationMailTemplate < ActiveRecord::Migration[7.0]
  def change
    Decidim::AdminExtended::MailTemplatesGenerator.new.create_template(:answer_questionnaire_confirmation_to_public_user)
  end
end
