# frozen_string_literal: true

module Decidim
  module CustomAi
    module AdminLog
      # This class holds the logic to present a `Decidim::Forms::Answer`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    TagPresenter.new(action_log, view_helpers).present
      class AnswerPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            ai_decision_body: :string,
            status: :string,
            ai_decision_status: :string,
            ai_is_complicated: :boolean
          }
        end

        def action_string
          case action.to_s
          when "update", "decidim_forms_answers_export", "decidim_forms_answers_import", "answers_ai_decision_regenerate"
            "decidim.admin_log.custom_ai_answer.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.answer"
        end

        def i18n_params
          super.merge({component_name: action_log.extra.dig("component", "title", "pl") })
        end
      end
    end
  end
end
