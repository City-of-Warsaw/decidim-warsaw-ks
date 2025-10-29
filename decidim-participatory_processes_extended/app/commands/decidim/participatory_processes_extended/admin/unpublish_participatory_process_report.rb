# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A command with all the business logic to publish report for participatory process
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
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:no_report_added) if @no_report_added

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
            participatory_process.update(attributes)
          end
        end

        # Private: Hash of main page process attributes

        def attributes
          {
            report_notification_send: false,
            consultation_status: ''
          }
        end
      end
    end
  end
end
