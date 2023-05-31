# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    module AdminLog
      class ArticleCategoryPresenter < Decidim::Log::BasePresenter

        private

        def diff_fields_mapping
          {
            title: :string,
            body: :text
          }
        end

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.admin_log.article_category.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.article_category"
        end

        def diff_actions
          super + %w(delete)
        end
      end
    end
  end
end
