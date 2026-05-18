# frozen_string_literal: true

module Decidim
  module CustomAi
    class RegenerateAnswerDecisionJob < ApplicationJob
      queue_as :default

      def perform(user_answers_ids, component, user)
        answers_list(user_answers_ids).each do |answer|
          next if answer.body.blank?

          ai_response = Decidim::CustomAi::AiApi.new("send_answer_body", request_data(answer, component)).fetch
          unless ai_response[:error].nil?
            Sentry.capture_message("Blad przetwarzania odpowiedzi RegenerateAnswerDecisionJob dla #{answer.id} - dopowiedz AI: #{ai_response[:error]}")

            next
          end

          answer.update(ai_decision_status: ai_response["ai_decision_status"],
                        ai_decision_body: ai_response["ai_decision_body"],
                        ai_suggestion_body: ai_response["suggestion_body"],
                        ai_is_complicated: ai_response["ai_is_complicated"])

          create_answer_version(answer, user)
        end
        notify_receiver_about_answers_ai_decision_update(user)
        create_log_about_answers_ai_decision_update(user, user_answers_ids, component)
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

      def create_log_about_answers_ai_decision_update(user, user_answers_ids, component)
        # Tylko dla wyswietlenia poprawnego logu - bierzemy pierwszy element
        resource = answers_list(user_answers_ids).first
        Decidim.traceability.perform_action!(
          :answers_ai_decision_regenerate,
          resource,
          user,
          log_info(resource, component)
        )
      end

      def log_info(resource, component)
        {
          participatory_space: {
            title: component.participatory_space.title,
            manifest_name: "participatory_processes"
          },
          component: {
            title: component.name,
            manifest_name: component.manifest_name
          },
          visibility: "admin-only"
        }
      end
      def notify_receiver_about_answers_ai_decision_update(receiver)
        return if receiver.email.blank?

        Decidim::CoreExtended::TemplatedMailer.notify(
          "decidim_forms_answers_ai_decision_regenerate",
          receiver,
          passed_data: nil
        ).deliver_later
      end
    end
  end
end
