# frozen_string_literal: true

module Decidim
  module ConsultationMap
    # This class handles search and filtering of user_questions. Needs a
    # `current_component` param with a `Decidim::Component` in order to
    # find the user_questions.
    class RemarkSearch < ResourceSearch
      text_search_fields :body

      # Public: Initializes the service.
      # component     - A Decidim::Component to get the user_questions from.
      # page        - The page number to paginate the results.
      # per_page    - The number of questions to return per page.
      def initialize(options = {})
        scope = options.fetch(:scope, Decidim::ConsultationMap::Remark.not_hidden)
        super(scope, options)
      end

      def base_query
        raise "Missing component" unless component

        @scope.where(decidim_component_id: component.id)
      end

      def search_search_text
        return query if search_text.blank?

        query.where("body ILIKE ?", "%#{search_text}%")
      end

      def search_decidim_category_id
        return query if decidim_category_id.blank?

        query.where(decidim_category_id: decidim_category_id)
      end
    end
  end
end
