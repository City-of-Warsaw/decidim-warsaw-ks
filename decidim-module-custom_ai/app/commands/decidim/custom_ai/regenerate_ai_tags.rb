# frozen_string_literal: true

module Decidim
  module CustomAi
    # A command with all the business logic when regenerating tags for all questions/answers from AI.
    class RegenerateAiTags < Decidim::Command
      # Public: Initializes the command.
      #
      # component_id - A id of current_component
      # current_user - A object with user data.
      def initialize(component, current_user)
        @component = component
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:ok) if regenerate_ai_tags

        broadcast(:invalid)
      end

      private

      attr_reader :component

      def regenerate_ai_tags
        Decidim::CustomAi::RegenerateTagsForAnswersJob.perform_later(component)
      end

    end
  end
end
