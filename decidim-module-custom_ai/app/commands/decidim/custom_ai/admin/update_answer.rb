# frozen_string_literal: true

module Decidim
  module CustomAi
    module Admin
      # A command with all the business logic when updating an Answer
      class UpdateAnswer < Decidim::Command
        attr_reader :form, :answer

        # Public: Initializes the command.
        #
        # answer - An Answer to update.
        # form - A form object with the params.
        def initialize(answer, form)
          @answer = answer
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_answer
          create_answer_version
          broadcast(:ok, answer)
        end

        private

        # Private method
        #
        # Updates answer
        def update_answer
          Decidim.traceability.update!(
            answer,
            current_user,
            attributes,
            log_info
          )
        end

        # Private: extra attributes for decidim forms answer
        #
        # Returns Hash
        def attributes
          {
            ai_decision_body: form.ai_decision_body,
            ai_is_complicated: form.ai_is_complicated
          }.tap do |attrs|
            attrs[:status] = form.status if form.status.present?
            attrs[:ai_decision_status] = form.ai_decision_status if form.ai_decision_status.present?
          end
        end

        def log_info
          {
            resource: {
              title: answer.body
            },
            participatory_space: {
              title: form.current_component.participatory_space.title,
              manifest_name: "participatory_processes"
            },
            component: {
              title: form.current_component.name,
              manifest_name: form.current_component.manifest_name
            },
            visibility: "admin-only"
          }
        end

        def create_answer_version
          Decidim::CustomAi::AnswerVersion.create(
            answer:,
            user: current_user,
            ai_decision_status: answer.ai_decision_status,
            status: answer.status,
            ai_decision_body: answer.ai_decision_body
          )
        end
      end
    end
  end
end
