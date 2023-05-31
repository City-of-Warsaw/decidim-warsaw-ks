# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module AdminLog
      class ExpertPresenter < Decidim::Log::BasePresenter

        private

        def diff_fields_mapping
          {
            position: :string,
            affiliation: :string,
            description: :string,
            weight: :integer,
            published_at: :date
          }
        end

        def action_string
          case action
          when "create", "delete", "update", "publish", "unpublish"
            "decidim.admin_log.expert.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.expert"
        end

        def diff_actions
          super + %w(delete publish unpublish)
        end
      end
    end
  end
end
