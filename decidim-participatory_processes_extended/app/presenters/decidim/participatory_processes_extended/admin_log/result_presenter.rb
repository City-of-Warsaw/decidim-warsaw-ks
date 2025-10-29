# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module AdminLog
      # This class holds the logic to present a `Decidim::ParticipatoryProcessesExtended::Result`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ResultPresenter.new(action_log, view_helpers).present
      class ResultPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            name: :string,
            body: :text,
            published: :boolean,
            weight: :integer,
            added_at: :date
          }
        end

        def action_string
          case action
          when "create", "publish", "update"
            "decidim.admin_log.result.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.result"
        end

        def diff_actions
          super
        end
      end
    end
  end
end
