# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Repository
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
            []
          end

          def search_field_predicate
            :name_or_description_cont
          end
        end
      end
    end
  end
end
