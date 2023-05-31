# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
      class UpdateExpertAnswer < Rectify::Command
        # Initializes a CreateExpertAnswer Command.
        #
        # form - The form from which to get the data.
        # current_user - The current instance of the expert to be updated.
        def initialize(form, expert_answer)
          @form = form
          @expert_answer = expert_answer
          @user_question = expert_answer.user_question
          @current_user = form.current_user
        end

        # Updates the expert if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          update_expert_answer
          broadcast(:ok)
        end

        private

        def update_expert_answer
          Decidim.traceability.update!(
            @expert_answer,
            @current_user,
            expert_answer_attributes,
            log_info
          )
        end

        def expert_answer_attributes
          {
            body: @form.body,
            files: @form.files
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
      end
    end
  end
end
