# frozen_string_literal: true

module Decidim
  module CustomAi
    class GetAnswerDecisionJob < ApplicationJob
      queue_as :default

      def perform(user_answers_ids, component)
        answers_list(user_answers_ids).each do |answer|
          next if answer.body.blank?

          ai_response = Decidim::CustomAi::AiApi.new("send_answer_body", request_data(answer, component)).fetch
          unless ai_response[:error].nil?
            Sentry.capture_message("Blad przetwarzania odpowiedzi GetAnswerDecisionJob dla #{answer.id} - dopowiedz AI: #{ai_response[:error]}")

            next
          end

          answer.update(ai_decision_status: ai_response["ai_decision_status"],
                        ai_decision_body: ai_response["ai_decision_body"],
                        ai_suggestion_body: ai_response["suggestion_body"],
                        ai_is_complicated: ai_response["ai_is_complicated"])
          next unless ai_response["tags_list"].present? && ai_response["tags_list"].any?

          actual_tag_list(component).where(name: ai_response["tags_list"]).each do |tag|
            answer.tags << tag
          end
        end
      end

      private

      def answers_list(user_answers_ids)
        Decidim::Forms::Answer.where(id: user_answers_ids)
      end

      def request_data(answer, component)
        {
          "answer_id": answer.id,
          "answer_body": answer.body.to_s.gsub(/[\"\'“”„«»]/, ""),
          "question_body": answer.question.body["pl"],
          "tag_list": actual_tag_list(component).pluck(:name),
          "component_id": component.id
        }
      end

      def actual_tag_list(component)
        Decidim::CustomAi::Tag.where(component:)
      end
    end
  end
end
