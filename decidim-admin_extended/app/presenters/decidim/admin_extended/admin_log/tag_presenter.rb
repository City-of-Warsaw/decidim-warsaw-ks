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
    #    TagPresenter.new(action_log, view_helpers).present
    class TagPresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          name: :string
        }
      end

      def action_string
        case action
        when "create", "delete", "update"
          "decidim.admin_log.tag.#{action}"
        else
          super
        end
      end

      def i18n_labels_scope
        "activemodel.attributes.tag"
      end

      def diff_actions
        super + %w(delete)
      end
    end
  end
end
