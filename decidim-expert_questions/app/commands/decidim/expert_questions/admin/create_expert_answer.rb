# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      class CreateExpertAnswer < Decidim::Command
        # Initializes a CreateExpertAnswer Command.
        def initialize(form)
          @form = form
          @current_user = form.current_user
          @user_question = form.user_question
          @expert = form.expert
        end

        # Creates the expert answer if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          create_expert_answer
          set_user_question_status_as_answered
          broadcast(:ok)
        end

        private

        def create_expert_answer
          @expert_answer = Decidim.traceability.create!(
            Decidim::ExpertQuestions::ExpertAnswer,
            @current_user,
            expert_answer_attributes,
            log_info
          )
        end

        def expert_answer_attributes
          {
            body: @form.body,
            files: @form.files,
            expert: @expert,
            user_question: @user_question
          }
        end

        def log_info
          {
            participatory_space: {
              title: @user_question.participatory_space.title
            }
          }
        end

        def set_user_question_status_as_answered
          @user_question.update_column(:status, "answered")
        end
      end
    end
  end
end
