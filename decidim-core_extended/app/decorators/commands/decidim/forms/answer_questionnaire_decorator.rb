# frozen_string_literal: true

Decidim::Forms::AnswerQuestionnaire.class_eval do
  # overwritten method
  # add create questionnaires user data
  # add send notification (our custom mail notifications)
  # add notify ai about answers
  # in broadcast ok pass also sessions token
  def call
    return broadcast(:invalid) if @form.invalid? || user_already_answered?

    with_events do
      answer_questionnaire
    end
    create_questionnaires_user_data
    send_notification

    if current_component.ai_enabled?
      answers = Decidim::Forms::Answer.where(user: current_user,
                                             questionnaire: @questionnaire,
                                             question: { question_type: "long_answer" },
                                             session_token: form.context.session_token).joins(:question)

      notify_ai_about_answers(answers)
    end

    if @errors
      reset_form_attachments
      broadcast(:invalid)
    else
      broadcast(:ok, form.context.session_token)
    end
  end

  private

  def notify_ai_about_answers(user_answers)
    Decidim::CustomAi::GetAnswerDecisionJob.perform_later(user_answers.pluck(:id), current_component)
    Decidim::CustomAi::RateAnswerJob.perform_later(user_answers.pluck(:id), current_component)
  end

  # overwritten method
  # add create_answer_version(answer) method
  def answer_questionnaire
    @main_form = @form
    @errors = nil

    Decidim::Forms::Answer.transaction(requires_new: true) do
      form.responses_by_step.flatten.select(&:display_conditions_fulfilled?).each do |form_answer|
        answer = Decidim::Forms::Answer.new(
          user: current_user,
          questionnaire: @questionnaire,
          question: form_answer.question,
          body: form_answer.body,
          session_token: form.context.session_token,
          ip_hash: form.context.ip_hash
        )

        build_choices(answer, form_answer)

        answer.save!
        create_answer_version(answer) # custom

        next unless form_answer.question.has_attachments?

        # The attachments module expects `@form` to be the form with the
        # attachments
        @form = form_answer
        @attached_to = answer

        build_attachments

        if attachments_invalid?
          @errors = true
          next
        end

        create_attachments if process_attachments?
        document_cleanup!
      end

      @form = @main_form
      raise ActiveRecord::Rollback if @errors
    end
  end

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

  def create_answer_version(new_answer)
    Decidim::CustomAi::AnswerVersion.create(
      answer: new_answer,
      user: nil,
      ai_decision_status: nil,
      status: nil,
      ai_decision_body: nil
    )
  end
end
