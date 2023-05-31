# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    class UserQuestionCell < Decidim::ViewModel
      include Cell::ViewModel::Partial

      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/expert_questions/user_question_m"
      end
    end
  end
end
