# frozen_string_literal: true

module Decidim::ExpertQuestions
  class Admin::ExpertAnswersController < Admin::ApplicationController
    helper_method :expert_answer, :user_question

    def new
      enforce_permission_to :create, :expert_answer, user_question: user_question
      @form = form(Decidim::ExpertQuestions::Admin::ExpertAnswerForm).instance
    end

    def create
      enforce_permission_to :create, :expert_answer, user_question: user_question
      @form = form(Decidim::ExpertQuestions::Admin::ExpertAnswerForm).from_params(params)

      Decidim::ExpertQuestions::Admin::CreateExpertAnswer.call(@form) do
        on(:ok) do
          flash[:notice] = I18n.t("expert_answers.create.success", scope: "decidim.expert_questions.admin")
          redirect_to expert_user_questions_path(expert_id: @form.expert.id)
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("expert_answers.create.invalid", scope: "decidim.expert_questions.admin")
          render action: "new"
        end
      end
    end

    def edit
      enforce_permission_to :update, :expert_answer, expert_answer: expert_answer
      @form = form(Decidim::ExpertQuestions::Admin::ExpertAnswerForm).from_model(expert_answer)
    end

    def update
      enforce_permission_to :update, :expert_answer, expert_answer: expert_answer
      @form = form(Decidim::ExpertQuestions::Admin::ExpertAnswerForm).from_params(params)

      Decidim::ExpertQuestions::Admin::UpdateExpertAnswer.call(@form, expert_answer) do
        on(:ok) do
          flash[:notice] = I18n.t("expert_answers.update.success", scope: "decidim.expert_questions.admin")
          redirect_to expert_user_questions_path(expert_id: @form.expert.id)
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("expert_answers.update.invalid", scope: "decidim.expert_questions.admin")
          render action: "edit"
        end
      end
    end

    def publish
      enforce_permission_to :publish, :expert_answer

      Decidim::ExpertQuestions::Admin::PublishExpertAnswer.call(expert_answer, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("expert_answers.publish.success", scope: "decidim.expert_questions.admin")
        end

        on(:invalid) do
          flash[:alert] = I18n.t("expert_answers.publish.invalid", scope: "decidim.expert_questions.admin")
        end
        redirect_to expert_user_questions_path(expert_id: expert_answer.expert.id)
      end
    end

    def unpublish
      enforce_permission_to :publish, :expert_answer
      Decidim::ExpertQuestions::Admin::UnpublishExpertAnswer.call(expert_answer, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("expert_answers.unpublish.success", scope: "decidim.expert_questions.admin")
        end

        on(:invalid) do
          flash[:alert] = I18n.t("expert_answers.unpublish.invalid", scope: "decidim.expert_questions.admin")
        end
        redirect_to expert_user_questions_path(expert_id: expert_answer.expert.id)
      end
    end

    private

    def expert_answers
      @expert_answers ||= Decidim::ExpertQuestions::ExpertAnswer.where(user_question: user_question).page(params[:page]).per(15)
    end

    def expert_answer
      @expert_answer ||= expert_answers.find(params[:id]) if params[:id]
    end

    def user_question
      @user_question ||= Decidim::ExpertQuestions::UserQuestion.find(params[:user_question_id]) if params[:user_question_id]
    end
  end
end
