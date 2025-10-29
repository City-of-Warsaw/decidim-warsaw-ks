# frozen_string_literal: true

Decidim::Forms::AnswerQuestionnaire.class_eval do
  # overwritten method
  # add create questionnaires user data
  def call
    return broadcast(:invalid) if @form.invalid? || user_already_answered?

    with_events do
      answer_questionnaire
    end
    create_questionnaires_user_data
    send_notification

    if @errors
      reset_form_attachments
      broadcast(:invalid)
    else
      broadcast(:ok, form.context.session_token)
    end
  end

  private

  def create_questionnaires_user_data
    @questionnaires_user_data = Decidim::Forms::QuestionnairesUserData.create(
      questionnaire: @questionnaire,
      # if unregistered author, take form email
      email: current_user ? current_user.email : form.email,
      uuid: SecureRandom.hex(16),
      session_token: form.context.session_token
    )
  end

  def send_notification
    Decidim::CoreExtended::TemplatedMailerJob.perform_later(
      "answer_questionnaire_confirmation_to_public_user",
      { resource: @questionnaires_user_data }
    )
  end
end
