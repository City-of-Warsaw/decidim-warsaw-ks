# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      class PublishExpertAnswer < Decidim::Command
        def initialize(expert_answer, current_user)
          @expert_answer = expert_answer
          @current_user = current_user
        end

        # Publish the expert answer if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if expert_answer.published?
          return broadcast(:invalid) unless [expert_answer.component,
                                             expert_answer.expert,
                                             expert_answer.user_question].all?(&:published?)

          publish_expert_answer
          send_notification
          broadcast(:ok)
        end

        private

        attr_reader :expert_answer, :current_user

        def publish_expert_answer
          Decidim.traceability.perform_action!(
            :publish,
            expert_answer,
            current_user,
            visibility: "all"
          ) do
            expert_answer.publish!
            expert_answer
          end
        end

        def send_notification
          Decidim::CoreExtended::TemplatedMailerJob.perform_later(
            "experts_answer_to_user_question",
            { resource: expert_answer, user_question: expert_answer.user_question, expert: expert_answer.expert }
          )
        end
      end
    end
  end
end
