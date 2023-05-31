# frozen_string_literal: true

module Decidim
  module AdminExtended::AdminLog
    # This class holds the logic to present a `Decidim::AdminExtended::Department`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    DepartmentPresenter.new(action_log, view_helpers).present
    class DepartmentPresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          name: :string
        }
      end

      def action_string
        case action
        when "create", "delete", "update"
          "decidim.admin_log.department.#{action}"
        else
          super
        end
      end

      def i18n_labels_scope
        "activemodel.attributes.department"
      end

      def diff_actions
        super + %w(delete)
      end
    end
  end
end
