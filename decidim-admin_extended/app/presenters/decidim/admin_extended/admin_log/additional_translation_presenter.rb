# frozen_string_literal: true

module Decidim
  module AdminExtended::AdminLog
    # This class holds the logic to present a `Decidim::AdminExtended::AdditionalTranslation`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    AdditionalTranslationPresenter.new(action_log, view_helpers).present
    class AdditionalTranslationPresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          value: :string
        }
      end

      def action_string
        case action
        when "update"
          "decidim.admin_log.additional_translation.#{action}"
        else
          super
        end
      end

      def i18n_labels_scope
        "activemodel.attributes.department"
      end

      def i18n_params
        super.merge(
          key: action_log.extra["resource"]["key"]
        )
      end

    end
  end
end
