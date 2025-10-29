# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    class UserQuestionCell < Decidim::ViewModel
      def show
        cell card_size, model, options
      end

      private

      def card_size
        case @options[:size]
        when :l
          "decidim/expert_questions/user_question_l"
        else
          "decidim/expert_questions/user_question_s"
        end
      end
    end
  end
end
