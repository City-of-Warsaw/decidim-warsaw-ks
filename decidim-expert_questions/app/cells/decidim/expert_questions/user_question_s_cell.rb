# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    class UserQuestionSCell < Decidim::CardSCell
      def len
        @options[:length] || 210
      end

      def description
        text = model.body

        decidim_sanitize(truncate(strip_tags(strip_links(text)), length: len))
      end

      def participatory_space_class_name
        model.component.participatory_space.class.model_name.human
      end

      def participatory_space_title
        decidim_escape_translated model.component.participatory_space.title
      end

      def participatory_space_path
        resource_locator(model.component.participatory_space).path
      end
    end
  end
end
