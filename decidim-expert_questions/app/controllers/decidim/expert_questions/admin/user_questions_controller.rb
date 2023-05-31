# frozen_string_literal: true

module Decidim::ExpertQuestions
  class Admin::UserQuestionsController < Admin::ApplicationController
    helper_method :user_questions, :expert

    def index
      enforce_permission_to :read, :user_questions, expert: expert
    end

    # controller action for exporting user questions data to xls file
    def export
      enforce_permission_to :read, :user_questions, expert: expert

      # create_log(current_user, 'experts_export')
      respond_to do |format|
        format.xlsx
      end
    end

    private

    def user_questions
      @user_questions ||= if current_user.ad_admin? || current_user.ad_coordinator?
                            expert.user_questions.latest_first.joins(:expert).where('decidim_expert_questions_experts.decidim_component_id': current_component.id).page(params[:page]).per(15)
                          elsif current_user.ad_expert? && expert && expert.user == current_user
                            expert.user_questions.latest_first.joins(:expert).where('decidim_expert_questions_experts.decidim_component_id': current_component.id).page(params[:page]).per(15)
                          end
    end

    def expert
      @expert ||= Decidim::ExpertQuestions::Expert.find(params[:expert_id])
    end
  end
end
