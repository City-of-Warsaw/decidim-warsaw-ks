# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    #
    # A dummy presenter to abstract out the unregistered author.
    #
    class UserQuestionPresenter < SimpleDelegator
      def initialize(params = {})
        @expert_name = params[:expert_name]
        @signature = params[:signature]
      end

      def name
        I18n.t("decidim.expert_questions.presenters.user_questions.name", expert_name: @expert_name)
      end
    end
  end
end
