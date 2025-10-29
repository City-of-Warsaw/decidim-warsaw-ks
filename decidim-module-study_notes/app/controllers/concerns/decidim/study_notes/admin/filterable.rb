# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module StudyNotes
    module Admin
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          def base_query
            collection
          end

          def search_field_predicate
            :id_string_or_sequential_number_string_or_submitter_data_first_name_or_submitter_data_last_name_or_submitter_data_org_name_or_signum_nr_kancelaryjny_cont
          end

          def filters
            [:submitter_data_role_eq]
          end

          def filters_with_values
            {
              submitter_data_role_eq: %w(0 1)
            }
          end

          def allowed_query_params
            [*extra_allowed_params, { q: ActionController::Parameters.permit_all_parameters }]
          end

          def query_params
            params.permit!.to_h.deep_symbolize_keys
          end
        end
      end
    end
  end
end
