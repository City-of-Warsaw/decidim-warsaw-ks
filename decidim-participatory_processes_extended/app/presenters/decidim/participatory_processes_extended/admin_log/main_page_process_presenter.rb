# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module AdminLog
      # This class holds the logic to present a `Decidim::ParticipatoryProcess`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ParticipatoryProcessPresenter.new(action_log, view_helpers).present
      class MainPageProcessPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            decidim_participatory_process_id: :string,
            weight: :string,
          }
        end

        def action_string
          case action
          when "create", "update", "delete"
            "decidim.admin_log.main_page_process.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.main_page_process"
        end

        def diff_actions
          super
        end
      end
    end
  end
end
