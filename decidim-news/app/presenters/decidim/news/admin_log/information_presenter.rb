# frozen_string_literal: true

module Decidim
  module News
    module AdminLog
      # This class holds the logic to present a `Decidim::News::Information`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    InformationPresenter.new(action_log, view_helpers).present
      class InformationPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            title: :string,
            body: :text,
            weight: :integer,
            added_on: :date
          }
        end

        def action_string
          case action
          when 'create',
               'delete',
               'update',
               'publish',
               'unpublish'

            "decidim.admin_log.information.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          'activemodel.attributes.information'
        end

        def diff_actions
          super + %w[delete]
        end
      end
    end
  end
end
