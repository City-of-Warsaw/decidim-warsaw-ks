# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    # This class handles search and filtering of user_questions. Needs a
    # `current_component` param with a `Decidim::Component` in order to
    # find the user_questions.
    class UserQuestionSearch
      # text_search_fields :body

      # Public: Initializes the service.
      # component - current component
      # options - filters
      # user - current user - questions author
      def initialize(component, options = {}, user = nil)
        @component = component
        @options = options.presence || {}
        @user = user
        @query = Decidim::ExpertQuestions::UserQuestion

        @options[:expert] = Array(@options[:expert]).compact_blank if @options[:expert]
      end

      attr_reader :options

      def search
        @query.for_component(@component.id)
              .yield_self { |q| search_expert(q) }
              .yield_self { |q| search_state(q) }
              .yield_self { |q| search_text(q) }
              .yield_self { |q| search_activity(q) }
      end

      # Handle the expert filter
      def search_expert(query)
        return query if filter_blank?(:expert)

        query.joins(:expert).where(decidim_expert_questions_experts: { id: options[:expert] })
      end

      # Handle the state filter
      def search_state(query)
        case options[:state]
        when "not_answered"
          query.not_answered
        when "public_answer"
          query.public_answer
        else
          query
        end
      end

      def search_text(query)
        return query if filter_blank?(:search_text)

        # query.where("body ILIKE ?", "%#{options[:search_text].strip}%")
        query.where("decidim_expert_questions_user_questions.body ILIKE ?", "%#{options[:search_text].strip}%")
      end

      # Handle the activity filter
      def search_activity(query)
        case options[:activity]
        when "my_user_questions"
          query.where(decidim_author_id: @user.id)
        else
          query
        end
      end

      private

      def filter_blank?(key)
        val = options[key]
        val.blank? || val == "all" || (val.is_a?(Array) && val.compact_blank.empty?)
      end
    end
  end
end
