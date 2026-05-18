# frozen_string_literal: true

module Decidim
  module CustomAi
    class AnswersSerializer < Decidim::Exporters::Serializer
      include Decidim::CoreExtended::SerializerExportHelper

      def initialize(resource = nil)
        super(resource)
      end

      # Public: Get the order of columns for serializing a decidim forms answer.
      # Returns an Array of symbols representing the column order.
      def columns_order
        @columns_order ||= [
          :id,
          :id_answer_author,
          :ip_hash,
          :session_token,
          :question_body,
          :body,
          :created_at,
          :ai_suggestion_body_presence,
          :ai_decision_status,
          :ai_decision_body,
          :status,
          :ai_is_complicated,
          :answer_tags
        ]
      end

      def columns_definition
        @columns_definition ||= {
          id: {
            name: column_name_translation("id"),
            size: :auto,
            alignment: :right
          },
          id_answer_author: { name: column_name_translation("id_answer_author"), size: :auto },
          ip_hash: {
            name: column_name_translation("ip_hash"),
            size: :auto,
            convert_to_text: true
          },
          session_token: {
            name: column_name_translation("session_token"),
            size: :auto,
            convert_to_text: true
          },
          question_body: {
            name: column_name_translation("question_body"),
            size: :body,
            wrap_text: true
          },
          body: {
            name: column_name_translation("body"),
            size: :body,
            wrap_text: true
          },
          created_at: { name: column_name_translation("created_at"), size: :auto },
          ai_suggestion_body_presence: { name: column_name_translation("ai_suggestion_body_presence"), size: :auto },
          ai_decision_status: { name: column_name_translation("ai_decision_status"), size: :auto },
          ai_decision_body: {
            name: column_name_translation("ai_decision_body"),
            size: :body,
            wrap_text: true
          },
          status: { name: column_name_translation("status"), size: :auto },
          ai_is_complicated: { name: column_name_translation("ai_is_complicated"), size: :auto },
          answer_tags: { name: column_name_translation("answer_tags"), size: :auto }
        }
      end

      # Serializes a collection of answers into a flat array of hashes suitable for export.
      #
      # @param answers [Array<Decidim::Forms::Answer>] The collection of answers to serialize.
      # @return [Array<Hash>] A flat array of hashes representing each answer.
      def serialize_all(answers)
        answers.map { |answer| answer_attrs(answer) }
      end

      # Serializes a single answer into a base hash of attributes used for export.
      #
      # This method produces a hash of attributes for a answer
      #
      # @param answer [Decidim::Forms::Answer] The answer object to serialize.
      # @return [Hash] A hash of serialized attributes for the answer
      def answer_attrs(answer)
        {
          id: answer.id,
          id_answer_author: answer.user&.id.presence || "",
          ip_hash: answer.ip_hash.to_s,
          session_token: answer.session_token.to_s,
          question_body: answer.question.body["pl"],
          body: answer.body,
          created_at: answer.created_at,
          ai_suggestion_body_presence: I18n.t("booleans.#{answer.ai_suggestion_body.present?}"),
          ai_decision_status: ai_decision_status(answer),
          ai_decision_body: answer.ai_decision_body,
          status: I18n.t("enums.decidim.forms.answer.status.#{answer.status}"),
          ai_is_complicated: I18n.t("booleans.#{answer.ai_is_complicated?}"),
          answer_tags: answer.tags.pluck(:name).join(", ")
        }
      end

      private

      def column_name_translation(column)
        I18n.t(column, scope: "decidim.forms.answers.export.answer")
      end

      def column_width(key)
        case key
        when :auto then nil
        when :body then 100
        else
          30
        end
      end

      def ai_decision_status(answer)
        I18n.t("enums.decidim.forms.answer.ai_decision_status.#{answer.ai_decision_status}") if answer.ai_decision_status.present?
      end
    end
  end
end
