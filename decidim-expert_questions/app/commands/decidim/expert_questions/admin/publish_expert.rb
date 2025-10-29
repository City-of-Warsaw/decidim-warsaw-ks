# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      class PublishExpert < Decidim::Command
        def initialize(expert, current_user)
          @expert = expert
          @current_user = current_user
        end

        # Publish the expert if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) unless expert.component.published?
          return broadcast(:invalid) if expert.published?

          publish_expert
          create_system_followable_user_question
          broadcast(:ok)
        end

        private

        attr_reader :expert, :current_user

        def publish_expert
          Decidim.traceability.perform_action!(
            :publish,
            expert,
            current_user,
            visibility: "all"
          ) do
            expert.publish!
            expert
          end
        end

        # Private method
        # This method ensures that at least one user question exists for the expert,
        # allowing users to follow user questions even when no user-created user questions exist.
        # It creates a hidden system user question that serves as a followable entity.
        def create_system_followable_user_question
          return if Decidim::ExpertQuestions::UserQuestion.exists?(body: "system_generated_hidden_user_question", expert:)

          Decidim::ExpertQuestions::UserQuestion.create!(
            author: Decidim::User.first,
            body: "system_generated_hidden_user_question",
            expert:
          )
        end
      end
    end
  end
end
