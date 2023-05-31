# frozen_string_literal: true

module Decidim
  module ConsultationRequests
    module AdminLog
      class ConsultationRequestPresenter < Decidim::Log::BasePresenter

        private

        def diff_fields_mapping
          {
            title: :string,
            body: :text,
            date_of_request: :date,
            comments_allowed: :boolean
          }
        end

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.admin_log.consultation_request.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.consultation_request"
        end

        def diff_actions
          super + %w(delete)
        end
      end
    end
  end
end
