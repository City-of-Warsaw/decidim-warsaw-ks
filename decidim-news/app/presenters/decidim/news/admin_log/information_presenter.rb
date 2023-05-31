# frozen_string_literal: true

module Decidim
  module News
    module AdminLog
      class InformationPresenter < Decidim::Log::BasePresenter

        private

        def diff_fields_mapping
          {
            title: :string,
            body: :text
          }
        end

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.admin_log.information.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.information"
        end

        def diff_actions
          super + %w(delete)
        end
      end
    end
  end
end
