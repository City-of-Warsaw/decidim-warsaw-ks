# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
      class ExpertAnswerForm < Decidim::Form
        mimic :expert_answer

        attribute :body, String
        attribute :user_question_id, Integer
        attribute :files, [String]

        validates :body, presence: true
        validates :user_question_id, presence: true

        validate :user_question_exists

        def user_question_exists
          return unless user_question_id

          errors.add(:body, 'Coś poszło nie tak, spróbuj ponownie') unless user_question
        end

        def user_question
          @user_question ||= UserQuestion.find_by(id: user_question_id)
        end

        def expert
          @expert ||= user_question.expert
        end
      end
    end
  end
end
