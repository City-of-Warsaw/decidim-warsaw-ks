# frozen_string_literal: true

module Decidim
  module AdminExtended::AdminLog
    # This class holds the logic to present a `Decidim::AdminExtended::Tag`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    StatisticPresenter.new(action_log, view_helpers).present
    class StatisticPresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          name: :string,
          additional_statistic_number: :integer,
          visibility: :boolean
        }
      end

      def action_string
        case action
        when "create", "delete", "update"
          "decidim.admin_log.statistic.#{action}"
        else
          super
        end
      end

      def diff_actions
        super + %w(delete)
      end
    end
  end
end
