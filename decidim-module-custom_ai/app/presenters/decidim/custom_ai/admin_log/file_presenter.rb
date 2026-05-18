# frozen_string_literal: true

module Decidim
  module CustomAi
    module AdminLog
      # This class holds the logic to present a `Decidim::CustomAi::File`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    TagPresenter.new(action_log, view_helpers).present
      class FilePresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            description: :string
          }
        end

        def action_string
          case action
          when "create", "delete", "send_xlsx_file_to_ai_module"
            "decidim.admin_log.custom_ai_file.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.file"
        end

        def diff_actions
          super + %w(delete)
        end

        def i18n_params
          super.merge({component_name: action_log.extra.dig("component", "title", "pl") })
        end

      end
    end
  end
end
