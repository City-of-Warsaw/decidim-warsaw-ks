# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
      class UnpublishExpert < Rectify::Command
        # Initializes a PublishExpert Command.
        #
        # form - The form from which to get the data.
        # current_user - The current instance of the expert to be updated.
        def initialize(expert, current_user)
          @expert = expert
          @current_user = current_user
        end

        # Updates the expert if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) unless expert.published?

          unpublish_expert
          broadcast(:ok)
        end

        private

        attr_reader :expert, :current_user

        def unpublish_expert
          Decidim.traceability.perform_action!(
            :unpublish,
            expert,
            current_user,
            visibility: "all"
          ) do
            expert.unpublish!
            expert
          end
        end
      end
    end
  end
end
