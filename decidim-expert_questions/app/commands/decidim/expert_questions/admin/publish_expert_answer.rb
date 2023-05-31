# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
      class PublishExpertAnswer < Rectify::Command
        # Initializes a PublishExpert Command.
        #
        # form - The form from which to get the data.
        # current_user - The current instance of the expert to be updated.
        def initialize(expert_answer, current_user)
          @expert_answer = expert_answer
          @current_user = current_user
        end

        # Updates the expert if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if expert_answer.published?

          publish_expert_answer
          if expert_answer.component.published?
            generate_notification_for_user
            send_notifications
          end
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

        # send notification to author of question
        def generate_notification_for_user
          return unless user_question.author.is_a? Decidim::User

          Decidim::NotificationGeneratorJob.perform_later(
            "decidim.events.expert_answers.expert_answer_published",
            "Decidim::ExpertQuestions::ExpertAnswerPublishedEvent",
            expert_answer,
            [], # followers
            [user_question.author], # affected_users
            {}
          )
        end

        def send_notifications
          Decidim::ExpertQuestions::UserMailer.notify_about_answer(expert_answer.user_question).deliver_later
        end
      end
    end
  end
end
