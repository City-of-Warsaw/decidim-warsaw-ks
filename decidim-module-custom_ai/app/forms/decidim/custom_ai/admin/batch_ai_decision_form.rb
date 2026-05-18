# frozen_string_literal: true

require "obscenity/active_model"

module Decidim
  module CustomAi
    module Admin
      # This class holds a Form to save the questionnaire answers from Decidim's admin with 1 collective action
      class BatchAiDecisionForm < Decidim::Form
        attribute :ai_decision_body, String
        attribute :ai_decision_status, String
        attribute :answer_ids, Array, default: []

        # dostępne rozstrzygnięcia
        def available_ai_decision_statuses
          Decidim::Forms::Answer.ai_decision_statuses.keys.map do |k|
            [I18n.t("enums.decidim.forms.answer.ai_decision_status.#{k}", default: k.humanize), k]
          end
        end
      end
    end
  end
end
