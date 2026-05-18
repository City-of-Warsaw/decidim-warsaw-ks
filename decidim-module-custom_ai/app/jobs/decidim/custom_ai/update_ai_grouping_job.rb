# frozen_string_literal: true

module Decidim
  module CustomAi
    class UpdateAiGroupingJob < ApplicationJob
      queue_as :default

      def perform(_user, component)
        similar = get_grouping_for(component, "get_similar_answers")
        incorrect = get_grouping_for(component, "get_incorrect_answers")

        if similar.empty?
          Sentry.capture_message("Blad przetwarzania odpowiedzi - odpowiedz AI: #{similar} lub #{incorrect}")
        else
          update_similar_answers(component, similar["similar_groups"]) if similar.compact.any?
        end

        if incorrect.empty?
          Sentry.capture_message("Blad przetwarzania odpowiedzi - odpowiedz AI: #{similar} lub #{incorrect}")
        else
          update_incorrect_answers(component, incorrect["similar_groups"]) if incorrect.compact.any?
        end


      end

      private

      def update_incorrect_answers(component, incorrect)
        incorrect.each_with_index do |answer, index|
          answer.each do |id|
            answers_list(component).find_by(id: id).update(incorrect_group_id: index + 1)
          end
        end
      end

      def update_similar_answers(component, similar)
        similar.each_with_index do |answer, index|
          answer.each do |id|
            answers_list(component).find_by(id: id).update(similar_group_id: index + 1)
          end
        end
      end

      def get_grouping_for(component, name)
        ai_response = Decidim::CustomAi::AiApi.new(name, request_data(component)).fetch

        unless ai_response[:error].nil?
          Sentry.capture_message("Blad przetwarzania odpowiedzi #{name} - dopowiedz AI: #{ai_response[:error]}")

          return []
        end
        ai_response
      end

      def answers_list(component)
        surveys = Decidim::Surveys::Survey.find_by(component:).questionnaire.questions.where(question_type: "long_answer").map(&:id)
        Decidim::Forms::Answer.where(decidim_question_id: surveys)
      end

      def request_data(component)
        {
          "component_id": component.id
        }
      end
    end
  end
end
