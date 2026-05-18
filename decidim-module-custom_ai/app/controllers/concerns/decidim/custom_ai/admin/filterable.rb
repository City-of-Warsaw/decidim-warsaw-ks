# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module CustomAi
    module Admin
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          def base_query
            collection
          end

          def filters
            [:tag_eq, :is_complicated_eq, :other_grouping_eq,:ai_is_incomplete_eq,:ai_is_vulgar_eq,:ai_is_illogical_eq]
          end

          def filters_with_values
            {
              tag_eq: tags_list.pluck(:id),
              is_complicated_eq: [true, false],
              ai_is_vulgar_eq: [true, false],
              ai_is_incomplete_eq: [true, false],
              ai_is_illogical_eq: [true, false],
              other_grouping_eq: [1]
            }
          end

          def dynamically_translated_filters
            [:tag_eq]
          end

          def translated_tag_eq(id)
            tags_list.find(id).name.upcase_first
          end

          def tags_list
            Decidim::CustomAi::Tag.where(component: current_component)
          end
        end
      end
    end
  end
end
