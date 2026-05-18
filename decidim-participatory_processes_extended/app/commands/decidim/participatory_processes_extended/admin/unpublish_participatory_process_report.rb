# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A command with all the business logic to unpublish report for participatory process
      class UnpublishParticipatoryProcessReport < Decidim::Command
        # Public: Initializes the command.
        #
        # user - A user that performs action
        # participatory_process - participatory_process for action
        def initialize(participatory_process, user)
          @current_user = user
          @participatory_process = participatory_process
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        #
        # Returns nothing.
        def call
          unpublish_process_report
          broadcast(:ok)
        end

        private

        attr_reader :current_user, :participatory_process

        def unpublish_process_report
          Decidim.traceability.perform_action!(
            :unpublish_participatory_process_report,
            participatory_process,
            current_user
          ) do
            participatory_process.update(report_published: false, report_notification_send: false)
            participatory_process.set_consultation_status
          end
        end
      end
    end
  end
end
