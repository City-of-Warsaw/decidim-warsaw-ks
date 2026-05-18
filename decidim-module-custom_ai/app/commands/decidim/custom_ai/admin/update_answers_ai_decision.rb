# frozen_string_literal: true

module Decidim
  module CustomAi
    module Admin
      # A command with all the business logic when updating ai decision decidim forms answers
      class UpdateAnswersAiDecision < Decidim::Command
        # Public: Initializes the command.
        #
        # user - current user.
        # form - A form object with the params.
        def initialize(user, form)
          @user = user
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the collection blank and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if @form.answer_ids.blank?

          Decidim::CustomAi::UpdateAnswersAiDecisionJob.perform_later(@user, attributes)
          broadcast(:ok)
        end

        private

        # Private: extra attributes for decidim forms answer
        #
        # Returns Hash
        def attributes
          attrs = { ai_decision_body: @form.ai_decision_body, answer_ids: @form.answer_ids }
          attrs[:ai_decision_status] = @form.ai_decision_status unless @form.ai_decision_status.nil?
          attrs
        end
      end
    end
  end
end
