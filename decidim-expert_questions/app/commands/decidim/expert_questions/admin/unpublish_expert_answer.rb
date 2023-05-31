# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
      class UnpublishExpertAnswer < Rectify::Command
        # Initializes a PublishExpert Command.
        #
        # form - The form from which to get the data.
        # current_user - The current instance of the expert to be updated.
        def initialize(expert_answer, current_user)
          @expert_answer = expert_answer
          @current_user = current_user
        end

        # Updates the expert if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) unless expert_answer.published?

          unpublish_expert_answer
          broadcast(:ok)
        end

        private

        attr_reader :expert_answer, :current_user

        def unpublish_expert_answer
          Decidim.traceability.perform_action!(
            :unpublish,
            expert_answer,
            current_user,
            visibility: "all"
          ) do
            expert_answer.unpublish!
            expert_answer
          end
        end
      end
    end
  end
end
