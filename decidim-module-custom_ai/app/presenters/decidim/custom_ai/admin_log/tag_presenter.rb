# frozen_string_literal: true

module Decidim
  module CustomAi
    module AdminLog
      # This class holds the logic to present a `Decidim::CustomAi::Tag`
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
          when "create", "delete", "update", "generate_tags_from_ai", "destroy_all_of_that_component"
            "decidim.admin_log.custom_ai_tag.#{action}"
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
end
