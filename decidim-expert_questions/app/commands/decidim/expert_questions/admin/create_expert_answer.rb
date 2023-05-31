# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
      class CreateExpertAnswer < Rectify::Command
        # Initializes a CreateExpertAnswer Command.
        #
        # form - The form from which to get the data.
        # current_user - The current instance of the expert to be updated.
        def initialize(form)
          @form = form
          @current_user = form.current_user
          @user_question = form.user_question
          @expert = form.expert
        end

        # Updates the expert if valid.
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
            # resource: {
            #   # title: "Eksperta - #{Decidim::User.find(@form.decidim_user_id).name}"
            #   title: Decidim::User.find(@form.decidim_user_id).name
            # },
            participatory_space: {
              title: @user_question.participatory_space.title
            }
          }
        end

        def set_user_question_status_as_answered
          @user_question.update_column('status', 'answered')
        end
      end
    end
  end
end
