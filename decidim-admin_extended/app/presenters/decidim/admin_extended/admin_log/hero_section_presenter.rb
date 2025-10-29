# frozen_string_literal: true

module Decidim
  module AdminExtended::AdminLog
    # This class holds the logic to present a `Decidim::AdminExtended::HeroHeader`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    HeroHeaderPresenter.new(action_log, view_helpers).present
    class HeroSectionPresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          title: :string,
          description: :text,
        }
      end

      def action_string
        case action
        when "update"
          "decidim.admin_log.hero_section.#{action}"
        else
          super
        end
      end

      def i18n_labels_scope
        "activemodel.attributes.hero_header"
      end
    end
  end
end
