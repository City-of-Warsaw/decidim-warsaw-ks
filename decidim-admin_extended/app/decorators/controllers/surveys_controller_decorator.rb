# frozen_string_literal: true

Decidim::Surveys::SurveysController.class_eval do
  before_action :verify_users_action_availability, only: :answer
  before_action :check_user_responses, only: :show
  helper_method :responses_for_current_question,
                :responses_for_current_question_body,
                :responses_for_current_question_files,
                :responses_for_current_question_custom_body,
                :sorting_answer_in_correct_order,
                :user_with_token?,
                :matrix_answer_checked?,
                :matrix_answer_body

  def answer
    enforce_permission_to_answer_questionnaire

    @form = form(Decidim::Forms::QuestionnaireForm).from_params(params, session_token:, ip_hash:)

    Decidim::Forms::AnswerQuestionnaire.call(@form, questionnaire) do
      on(:ok) do |token|
        flash[:notice] = I18n.t("answer.success", scope: i18n_flashes_scope)
        redirect_to show_survey_responses_path(uuid: token)
      end

      on(:invalid) do
        flash.now[:alert] = I18n.t("answer.invalid", scope: i18n_flashes_scope)
        render template: "decidim/forms/questionnaires/show"
      end
    end
  end

  # overwriten method
  # add only_path
  def update_url
    url_for([questionnaire_for, { action: :answer, only_path: true }])
  end

  private

  def check_user_responses
    redirect_to Decidim::ResourceLocatorPresenter.new(@current_component.participatory_space).url if params[:uuid].present? && responses_for_current_participant.empty?
  end

  def responses_for_current_participant
    if params[:uuid].present?
      @session_token = params[:uuid]
      Decidim::Forms::QuestionnaireParticipants.new(questionnaire).query.where(session_token: @session_token)
    elsif @current_user
      Decidim::Forms::QuestionnaireParticipants.new(questionnaire).query.where(user: @current_user)
    end
  end

  def user_with_token?
    params[:uuid].present?
  end

  def responses_for_current_question(question)
    return {} if responses_for_current_participant.nil?

    responses_for_current_participant.where(question:).map(&:choices).flatten
  end

  def matrix_answer_checked?(question, row, answer_option)
    return false if responses_for_current_participant.nil?

    !!responses_for_current_question(question).find { |c| c.decidim_question_matrix_row_id == row.id && c.decidim_answer_option_id == answer_option.id }
  end

  def matrix_answer_body(question, row, answer_option)
    return {} if responses_for_current_participant.nil?

    responses_for_current_question(question).find { |c| c.decidim_question_matrix_row_id == row.id && c.decidim_answer_option_id == answer_option.id }&.custom_body
  end

  def sorting_answer_in_correct_order(answer)
    choice = responses_for_current_question(answer.question)
    if choice.any?
      order = choice.sort_by{|e| e[:position]}.map(&:decidim_answer_option_id)
      models_by_id = answer.question.answer_options.where(id: order).each_with_object([]) { |m,a| a[m.id] = m }
      order.collect { |id| models_by_id[id] }
    else
      answer.question.answer_options
    end
  end

  def responses_for_current_question_body(answer)
    return nil if responses_for_current_participant.nil?

    responses_for_current_participant.where(question: answer.question).first.try(:body)
  end

  def responses_for_current_question_custom_body(answer)
    return nil if responses_for_current_participant.nil?

    responses_for_current_participant.where(question: answer.question).first.try(:custom_body)
  end
  def responses_for_current_question_files(answer)
    return nil if responses_for_current_participant.nil?

    responses_for_current_participant.where(question: answer.question).map{ |response| response.attachments.map{|a| a.file.filename } }
  end

  def verify_users_action_availability
    redirect_to survey_path(survey), alert: current_component.end_date_message if current_component.users_action_disallowed? && !(current_user&.has_ad_role?)
  end
end
