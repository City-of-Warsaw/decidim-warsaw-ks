# frozen_string_literal: true

require_dependency 'file_form_validator'

module Decidim
  module ExpertQuestions
    module Admin
      # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
      class ExpertAnswerForm < Decidim::Form
        mimic :expert_answer

        attribute :body, String
        attribute :user_question_id, Integer
        attribute :files, [ActionDispatch::Http::UploadedFile]
        attribute :remove_files, [Integer]

        validates :body, presence: true
        validates :user_question_id, presence: true
        validates :files, file_form: {
          max_size: 50.megabytes,
          acceptable_types:
            %w[
              image/jpg image/jpeg image/gif image/png image/bmp application/pdf application/msword
              application/vnd.openxmlformats-officedocument.wordprocessingml.document
            ]
        }

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
