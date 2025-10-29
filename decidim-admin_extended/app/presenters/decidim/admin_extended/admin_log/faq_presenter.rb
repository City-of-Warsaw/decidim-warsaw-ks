# frozen_string_literal: true

module Decidim
  module AdminExtended
    module AdminLog
      # This class holds the logic to present a 'Decidim::AdminExtended::Faq'
      # for the 'AdminLog' log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    FaqPresenter.new(action_log, view_helpers).present
      class FaqPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            title: :string,
            content: :string,
            published: :boolean,
            weight: :integer,
            faq_group_id: :integer
          }
        end

        def generate_action_string(action)
          case action
          when "create", "delete", "update"
            "decidim.admin_log.faq.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.faq"
        end

        def diff_actions
          super + %w(delete)
        end
      end
    end
  end
end
