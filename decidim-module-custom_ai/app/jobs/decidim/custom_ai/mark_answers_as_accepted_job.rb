# frozen_string_literal: true

module Decidim
  module CustomAi
    class MarkAnswersAsAcceptedJob < ApplicationJob
      queue_as :events

      BATCH_SIZE = 500

      def perform(user, answer_ids)
        Decidim::Forms::Answer.where(id: answer_ids).find_in_batches(batch_size: BATCH_SIZE) do |batch|
          batch.each do |answer|
            answer.update!(status: :accepted)
            create_answer_version(answer, user)
          end
        end

        notify_receiver_about_answers_export(user)
      end

      private

      def create_answer_version(answer, user)
        Decidim::CustomAi::AnswerVersion.create(
          answer:,
          user:,
          ai_decision_status: answer.ai_decision_status,
          status: answer.status,
          ai_decision_body: answer.ai_decision_body
        )
      end

      def notify_receiver_about_answers_export(receiver)
        return if receiver.email.blank?

        Decidim::CoreExtended::TemplatedMailer.notify(
          "decidim_forms_answers_accepted",
          receiver,
          passed_data: nil
        ).deliver_later
      end
    end
  end
end
