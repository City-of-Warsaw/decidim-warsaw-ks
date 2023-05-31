# frozen_string_literal: true

module Decidim::ExpertQuestions
  class Admin::ExpertsController < Admin::ApplicationController
    helper_method :experts, :expert, :user_questions
    helper Decidim::ExpertQuestions::AdminHelper

    def index
      enforce_permission_to :read, :expert
    end

    # controller action for exporting questions data for all experts to xls file
    def export
      enforce_permission_to :read, :expert

      # create_log(current_user, 'experts_export')
      respond_to do |format|
        format.xlsx { render 'decidim/expert_questions/admin/user_questions/export'}
      end
    end

    def new
      enforce_permission_to :create, :expert
      @form = form(Decidim::ExpertQuestions::Admin::ExpertForm).instance
    end

    def create
      enforce_permission_to :create, :expert
      @form = form(Decidim::ExpertQuestions::Admin::ExpertForm).from_params(params).with_context(current_component: current_component, current_user: current_user)

      should_be_published = params[:publish] && allowed_to?(:publish, :expert)
      Decidim::ExpertQuestions::Admin::CreateExpert.call(@form, should_be_published) do
        on(:ok) do
          flash[:notice] = I18n.t("experts.create.success", scope: "decidim.expert_questions.admin")
          redirect_to experts_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("experts.create.invalid", scope: "decidim.expert_questions.admin")
          render action: "new"
        end
      end
    end

    def edit
      enforce_permission_to :update, :expert, expert: expert
      @form = form(Decidim::ExpertQuestions::Admin::ExpertForm).from_model(expert)
    end

    def update
      enforce_permission_to :update, :expert, expert: expert
      @form = form(Decidim::ExpertQuestions::Admin::ExpertForm).from_params(params).with_context(current_component: current_component, current_user: current_user)

      Decidim::ExpertQuestions::Admin::UpdateExpert.call(@form, expert) do
        on(:ok) do
          flash[:notice] = I18n.t("experts.update.success", scope: "decidim.expert_questions.admin")
          redirect_to experts_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("experts.update.invalid", scope: "decidim.expert_questions.admin")
          render action: "edit"
        end
      end
    end

    def destroy
      enforce_permission_to :destroy, :expert, expert: expert
      expert.destroy!

      flash[:notice] = I18n.t("experts.destroy.success", scope: "decidim.expert_questions.admin")

      redirect_to experts_path
    end

    def publish
      enforce_permission_to :publish, :expert

      Decidim::ExpertQuestions::Admin::PublishExpert.call(expert, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("experts.publish.success", scope: "decidim.expert_questions.admin")
        end

        on(:invalid) do
          flash[:alert] = I18n.t("experts.publish.invalid", scope: "decidim.expert_questions.admin")
        end
        redirect_to experts_path
      end
    end

    def unpublish
      enforce_permission_to :publish, :expert
      Decidim::ExpertQuestions::Admin::UnpublishExpert.call(expert, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("experts.unpublish.success", scope: "decidim.expert_questions.admin")
        end

        on(:invalid) do
          flash[:alert] = I18n.t("experts.unpublish.invalid", scope: "decidim.expert_questions.admin")
        end
        redirect_to experts_path
      end
    end

    private

    def experts
      @experts ||= Decidim::ExpertQuestions::Expert.where(component: current_component).page(params[:page]).per(15)
    end

    def expert
      @expert ||= experts.find(params[:id]) if params[:id]
    end

    # TODO: czy wszyscy moga eksportowac wszystkie pytania do ekspeta?
    def user_questions
      @user_questions ||= Decidim::ExpertQuestions::UserQuestion.joins(:expert).where('decidim_expert_questions_experts.decidim_component_id': current_component.id)
    end
  end
end
