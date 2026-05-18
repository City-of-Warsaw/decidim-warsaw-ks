# frozen_string_literal: true

module Decidim
  module CustomAi
    class RegenerateTagsForAnswersJob < ApplicationJob
      queue_as :default

      def perform(component)
        answers_list(component).each do |answer|
          next if answer.body.blank?
          
          ai_response = Decidim::CustomAi::AiApi.new("reassign_tags_to_answer", request_data(answer, component)).fetch

          unless ai_response[:error].nil?
            Sentry.capture_message("Blad przetwarzania odpowiedzi reasign_tags_to_answer dla #{answer.id} - dopowiedz AI: #{ai_response[:error]}")
            next
          end

          next unless ai_response["tags_list"].present? && ai_response["tags_list"].any?

          answer.tags.destroy_all

          actual_tag_list(component).where(name: ai_response["tags_list"]).each do |tag|
            answer.tags << tag
          end
        end
      end

      private

      def answers_list(component)
        surveys = Decidim::Surveys::Survey.find_by(component:).questionnaire.questions.where(question_type: "long_answer").map(&:id)
        Decidim::Forms::Answer.where(decidim_question_id: surveys)
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
