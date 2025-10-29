# frozen_string_literal: true

module Decidim
  module AdminExtended
    module AdminLog
      # This class holds the logic to present a 'Decidim::AdminExtended::FaqGroup'
      # for the 'AdminLog' log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    FaqGroupPresenter.new(action_log, view_helpers).present
      class FaqGroupPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            name: :string,
            subtitle: :string,
            published: :boolean,
            weight: :integer
          }
        end

        def generate_action_string(action)
          case action
          when "create", "delete", "update"
            "decidim.admin_log.faq_group.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.faq_group"
        end

        def diff_actions
          super + %w(delete)
        end
      end
    end
  end
end
