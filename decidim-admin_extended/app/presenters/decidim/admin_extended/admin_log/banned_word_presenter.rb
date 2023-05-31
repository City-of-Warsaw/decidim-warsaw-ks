# frozen_string_literal: true

module Decidim
  module AdminExtended::AdminLog
    # This class holds the logic to present a `Decidim::AdminExtended::BannedWord`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    BannedWordPresenter.new(action_log, view_helpers).present
    class BannedWordPresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          name: :string
        }
      end

      def action_string
        case action
        when "create", "delete", "update"
          "decidim.admin_log.banned_word.#{action}"
        else
          super
        end
      end

      def i18n_labels_scope
        "activemodel.attributes.banned_word"
      end

      def diff_actions
        super + %w(delete)
      end
    end
  end
end
