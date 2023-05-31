# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    # This class handles search and filtering of user_questions. Needs a
    # `current_component` param with a `Decidim::Component` in order to
    # find the user_questions.
    class UserQuestionSearch < ResourceSearch
      text_search_fields :body

      # Public: Initializes the service.
      # component     - A Decidim::Component to get the user_questions from.
      # page        - The page number to paginate the results.
      # per_page    - The number of questions to return per page.
      def initialize(options = {})
        scope = options.fetch(:scope, Decidim::ExpertQuestions::UserQuestion.not_hidden)
        super(scope, options)
      end

      def base_query
        raise "Missing component" unless component

        @scope.where(decidim_expert_questions_experts_id: Decidim::ExpertQuestions::Expert.where(decidim_component_id: component.id).map(&:id))
      end

      # Handle the state filter
      def search_expert
        return query if options[:expert].blank? || options[:expert] == "all"

        query.joins(:expert).where('decidim_expert_questions_experts.id': options[:expert])
      end

      # Handle the state filter
      def search_state
        apply_scopes(%w(not_answered public_answer), state)
      end

      # Handle the activity filter
      def search_activity
        case activity
        when "my_user_questions"
          query
            .where(decidim_author_id: user.id)
        else
          query
        end
      end

      def localized_search_text_in(field)
        ("#{field} ILIKE :text")
      end
    end
  end
end
