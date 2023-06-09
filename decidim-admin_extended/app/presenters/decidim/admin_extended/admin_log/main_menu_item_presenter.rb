# frozen_string_literal: true

module Decidim
  module AdminExtended::AdminLog
    # This class holds the logic to present a `Decidim::Area`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    AreaPresenter.new(action_log, view_helpers).present
    class MainMenuItemPresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          name: :string,
          weight: :integer,
          visible: :boolean
        }
      end

      def action_string
        case action
        when "update"
          "decidim.admin_log.main_menu_item.#{action}"
        else
          super
        end
      end

      def i18n_labels_scope
        "activemodel.attributes.main_menu_item"
      end
    end
  end
end
