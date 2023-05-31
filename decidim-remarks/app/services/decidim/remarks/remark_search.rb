# frozen_string_literal: true

module Decidim
  module Remarks
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
        scope = options.fetch(:scope, Decidim::Remarks::Remark.not_hidden)
        super(scope, options)
      end

      def base_query
        raise "Missing component" unless component

        @scope.where(component: component)
      end

      def localized_search_text_in(field)
        ("#{field} ILIKE :text")
      end
    end
  end
end
