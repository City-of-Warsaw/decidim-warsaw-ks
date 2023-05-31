# frozen_string_literal: true

module Decidim::ExpertQuestions
  class UserQuestionsController < Decidim::ExpertQuestions::ApplicationController
    include Decidim::FormFactory
    include Decidim::FilterResource
    include Decidim::Paginable
    include Decidim::Flaggable

    helper_method :experts, :expert, :user_questions, :user_question, :paginated_user_questions,
                  :questions_help_section, :user_question_token, :created_user_question

    before_action :verify_users_action_availability, only: [:new, :edit]

    def index
      enforce_permission_to :read, :user_question

      # @form = new_user_question_form

      respond_to do |format|
        format.html
        format.js
      end
    end

    def show
      enforce_permission_to :read, :user_question
      @user_questions = user_questions.where(id: params[:id])
      @user_question = user_questions.find_by(id: params[:id])
      # add premissions to see hidden modearate
      respond_to do |format|
        format.html { render :index }
        format.js
      end
    end

    def new
      enforce_permission_to :create, :user_question

      @form = form(Decidim::ExpertQuestions::UserQuestionForm).from_params(expert_id: expert.id)
    end

    def create
      enforce_permission_to :create, :user_question
      @form = form(Decidim::ExpertQuestions::UserQuestionForm).from_params(params)

      Decidim::ExpertQuestions::CreateUserQuestion.call(@form) do
        on(:ok) do
          session[:user_question_token] = Decidim::ExpertQuestions::UserQuestion.last.token
          respond_to do |format|
            format.js { render current_user ? :thank_you : :create }
            format.html { redirect_to user_questions_path, notice: I18n.t("user_questions.create_success", scope: "decidim.expert_question") }
          end
        end

        on(:invalid) do
          respond_to do |format|
            format.js { render :new }
            format.html { render :new, alert: I18n.t("user_questions.create.invalid", scope: "decidim.expert_questions") }
          end
        end
      end
    end

    # GET Action used for full edit
    def edit
      @user_question = if current_user
                         Decidim::ExpertQuestions::UserQuestion.user_user_questions(current_user.id).find_by(id: params[:id])
                       elsif session[:user_question_token].present?
                         Decidim::ExpertQuestions::UserQuestion.find_by(token: session[:user_question_token])
                       end
      if @user_question
        @form = form(Decidim::ExpertQuestions::UserQuestionForm).from_model(@user_question)
        respond_to do |format|
          format.html
          format.js
        end
      else
        respond_to do |format|
          format.html { redirect_to user_questions_path, alert: 'Cos poszło nie tak' }
          format.js { render js: "window.location.href='#{user_questions_path}'" }
        end
      end
    end

    def second_step_update
      @user_question = Decidim::ExpertQuestions::UserQuestion.find_by(token: session[:user_question_token]) if !current_user && session[:user_question_token].present?
      if @user_question
        @form = form(Decidim::ExpertQuestions::UserQuestionForm)
                .from_params(params.merge(body: @user_question.body))
        Decidim::ExpertQuestions::SecondStepUserQuestionUpdate.call(@form, @user_question) do
          on(:ok) do
            respond_to do |format|
              format.html { redirect_to user_questions_path, notice: I18n.t("user_questions.update.success", scope: "decidim.expert_questions") }
              format.js { render :thank_you }
            end
          end
          on(:invalid) do
            respond_to do |format|
              format.js { render :second_step_update_error }
            end
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to user_questions_path, alert: 'Coś poszło nie tak' }
          format.js { render js: "window.location.href='#{user_questions_path}'" }
        end
      end
    end

    # PATCH Action for full update
    def update
      @user_question = if current_user
                  Decidim::ExpertQuestions::UserQuestion.user_user_questions(current_user.id).find_by(id: params[:id])
                elsif session[:user_question_token].present?
                  Decidim::ExpertQuestions::UserQuestion.find_by(token: session[:user_question_token])
                end
      if @user_question
        @form = form(Decidim::ExpertQuestions::UserQuestionForm)
                .from_params(params.merge(rodo: true)) # passing rodo for validation pass
        Decidim::ExpertQuestions::UpdateUserQuestion.call(@form, @user_question, current_user) do
          on(:ok) do
            respond_to do |format|
              format.html { redirect_to user_questions_path, notice: I18n.t("user_questions.update.success", scope: "decidim.expert_question") }
              format.js { render :update }
            end
          end
          on(:invalid) do
            respond_to do |format|
              format.js { render :error }
            end
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to user_questions_path, alert: 'Cos poszło nie tak' }
          format.js { render js: "window.location.href='#{user_questions_path}'" }
        end
      end
    end

    private

    def experts
      @experts ||= Decidim::ExpertQuestions::Expert.published.where(component: current_component).page(params[:page]).per(15)
    end

    def expert
      @expert ||= if params[:expert_id]
                    experts.find_by(id: params[:expert_id])
                  elsif params[:user_question] && params[:user_question][:expert_id]
                    experts.find_by(id: params[:user_question][:expert_id])
                  end

      @expert ? @expert : (redirect_to(user_questions_path, alert: I18n.t("user_questions.new.expert_not_found", scope: "decidim.expert_questions")) and return)
    end

    def user_questions
      # @user_questions ||= Decidim::ExpertQuestions::UserQuestion.where(component: current_component).page(params[:page]).per(15)

      @user_questions ||= if params[:filter].blank?
                            search.results.order(:id)
                          elsif params[:filter][:sort] == "latest_first"
                            search.results.latest_first
                          else
                            search.results.order(:id)
                          end
    end

    def user_question
      @user_question ||= user_questions.find(params[:user_question_id])
    end

    # def new_user_question_form
    #   form(Decidim::ExpertQuestions::UserQuestionForm)
    #     .from_params(expert_id: expert.id)
    #     .with_context(current_component: current_component, current_user: current_user)
    # end

    def created_user_question
      if current_user
        Decidim::ExpertQuestions::UserQuestion.user_user_questions(current_user.id).last
      elsif session[:user_question_token]
        Decidim::ExpertQuestions::UserQuestion.find_by(token: session[:user_question_token])
      end
    end

    def user_question_token
      @user_question_token ||= session[:user_question_token]
    end

    def paginated_user_questions
      @paginated_user_questions ||= paginate(user_questions).includes(:expert)
    end

    def search_klass
      Decidim::ExpertQuestions::UserQuestionSearch
    end

    def default_search_params
      {
        page: params[:page],
        per_page: 12
      }
    end

    def default_filter_params
      {
        search_text: "",
        activity: "all",
        sort: "all",
        state: 'all',
        expert: ""
      }
    end

    def questions_help_section
      current_component.settings[:help_section]
    end

    def verify_users_action_availability
      if current_component.users_action_disallowed?
        redirect_to user_questions_path, alert: current_component.end_date_message
      end
    end
  end
end
