# frozen_string_literal: true

module Decidim
  module CustomAi
    class RateAnswerJob < ApplicationJob
      queue_as :default

      def perform(user_answers_ids, component)
        answers_list(user_answers_ids).each do |answer|
          next if answer.body.blank?

          ai_response = Decidim::CustomAi::AiApi.new("rate_answer_body", request_data(answer, component)).fetch
          unless ai_response[:error].nil?
            Sentry.capture_message("Blad przetwarzania odpowiedzi reasign_tags_to_answer dla #{answer.id} - dopowiedz AI: #{ai_response[:error]}")

            next
          end

          answer.update(ai_is_vulgar: ai_response["is_vulgar"],
                        ai_is_incomplete: ai_response["is_incomplete"],
                        ai_is_illogical: ai_response["is_illogical"])
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
