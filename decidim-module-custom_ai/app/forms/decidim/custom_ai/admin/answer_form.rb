# frozen_string_literal: true

require "obscenity/active_model"

module Decidim
  module CustomAi
    module Admin
      # This class holds a Form to save the questionnaire answers from Decidim's admin
      class AnswerForm < Decidim::Form
        attribute :ai_decision_body, String
        attribute :ai_decision_status, String
        attribute :status, String, default: "pending"
        attribute :ai_is_complicated, Boolean, default: false

        def map_model(model)
          self.status = model.status
          self.ai_decision_status = model.ai_decision_status
          self.ai_decision_body = model.ai_decision_body
          self.ai_is_complicated = model.ai_is_complicated
        end

        # dostępne rozstrzygnięcia
        def available_ai_decision_statuses
          Decidim::Forms::Answer.ai_decision_statuses.keys.map do |k|
            [I18n.t("enums.decidim.forms.answer.ai_decision_status.#{k}", default: k.humanize), k]
          end
        end

        # dostępne statusy uzasadnienia
        def available_statuses
          Decidim::Forms::Answer.statuses.keys.map do |k|
            [I18n.t("enums.decidim.forms.answer.status.#{k}", default: k.humanize), k]
          end
        end
      end
    end
  end
end
