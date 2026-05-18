# frozen_string_literal: true

module Decidim::ExpertQuestions
  class UserQuestionsController < Decidim::ExpertQuestions::ApplicationController
    include Decidim::FormFactory
    include Decidim::FilterResource
    include Decidim::Paginable
    include Decidim::Flaggable
    include Decidim::CoreExtended::CommentTokenCookie

    helper_method :experts,
                  :expert,
                  :user_questions,
                  :user_question,
                  :paginated_user_questions,
                  :user_question_token,
                  :created_user_question,
                  :first_followable_user_question,
                  :user_allowed_to_add_user_question?,
                  :user_questions_with_comments_count

    def index
      enforce_permission_to :read, :user_question

      respond_to do |format|
        format.html
        format.js
      end
    end

    def show
      enforce_permission_to :read, :user_question
      @user_questions = user_questions.where(id: params[:id])
      @user_question = user_questions.find_by(id: params[:id])

      raise ActionController::RoutingError, "Not Found" unless @user_question

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
            format.js { render :create_error }
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
          format.html { redirect_to user_questions_path, alert: "Cos poszło nie tak" }
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
          format.html { redirect_to user_questions_path, alert: "Coś poszło nie tak" }
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
        @form = form(Decidim::ExpertQuestions::UserQuestionForm).from_params(params)
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
          format.html { redirect_to user_questions_path, alert: "Cos poszło nie tak" }
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
      @expert || (redirect_to(user_questions_path, alert: I18n.t("user_questions.new.expert_not_found", scope: "decidim.expert_questions")) && (nil))
    end

    def user_questions
      @user_questions ||= begin
                            questions = searched_user_questions.without_system_hidden
                            if params.dig(:filter, :sort) == "latest_first"
                              questions.latest_first
                            else
                              questions.order(:id)
                            end
                          end
    end

    def searched_user_questions
      Decidim::ExpertQuestions::UserQuestionSearch.new(current_component, params[:filter], current_user).search
    end

    def user_question
      @user_question ||= user_questions.find(params[:user_question_id])
    end

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

    def default_filter_params
      {
        search_text: "",
        activity: "all",
        sort: "all",
        state: "all",
        expert: []
      }
    end

    # Returns the first user question in the database that belongs to current component
    # Thanks to the `create_system_followable_user_question` method in:
    # `decidim-admin_extended/app/decorators/commands/publish_component_decorator.rb`,
    # there will always be at least one user question available for users to follow.
    def first_followable_user_question
      return nil unless current_components_first_expert&.published?

      @first_followable_user_question ||= Decidim::ExpertQuestions::UserQuestion.where(
        expert: current_components_first_expert,
        body: "system_generated_hidden_user_question"
      ).order(:created_at).first
    end

    def current_components_first_expert
      @current_components_first_expert ||= Decidim::ExpertQuestions::Expert.published
                                                                           .where(component: current_component)
                                                                           .first
    end

    # user question's component settings be set in admin panel, to disallow to comment:
    # - if time set in the user question's component settings of the users_action_end_date field has passed
    # - participatory_space setting field: users_action_allowed_for_unregister_users
    def user_allowed_to_add_user_question?(user)
      # scenario when component is closed
      return false if current_component.users_action_end_date&.past?
      # scenario when registered user is present
      return true if user.present?

      # scenario when unregistered author is present
      current_component.participatory_space.users_action_allowed_for_unregister_users?
    end

    # Returns total count of not hidden user questions and all their not hidden comments (including nested)
    def user_questions_with_comments_count
      return 0 if user_questions.none?

      count = user_questions.not_hidden.count
      count += user_questions.map { |question| question.comments.not_hidden.count }.sum
      count
    end

  end
end
