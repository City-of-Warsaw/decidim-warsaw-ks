# frozen_string_literal: true

module Decidim
  module CustomAi
    module Admin
      # A command with all the business logic when exporting decidim forms answers
      class ScheduleAnswersExport < Decidim::Command
        # Public: Initializes the command.
        #
        # component - current component.
        # user - current user.
        # answers_ids - collection.
        # @resource - proxy answer for log resource.
        def initialize(component, user, collection)
          @component = component
          @user = user
          @answers_ids = collection.pluck(:id)
          @resource = collection.first
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the collection blank and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if @answers_ids.blank?

          Decidim::CustomAi::AnswersExportJob.perform_later(@user, @answers_ids)
          create_log(@resource, "decidim_forms_answers_export")

          broadcast(:ok)
        end

        private

        def create_log(resource, log_type)
          Decidim.traceability.perform_action!(
            log_type,
            resource,
            current_user,
            log_info(resource)
          )
        end

        def log_info(answer)
          {
            resource: {
              title: answer.body
            },
            participatory_space: {
              title: @component.participatory_space.title,
              manifest_name: "participatory_processes"
            },
            component: {
              title: @component.name,
              manifest_name: @component.manifest_name
            },
            visibility: "admin-only"
          }
        end
      end
    end
  end
end
