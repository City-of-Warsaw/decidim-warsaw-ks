# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A command with all the business logic to send notification of report for participatory process
      class SendNotificationForParticipatoryProcessReport < Decidim::Command
        # Public: Initializes the command.
        #
        # user - A user that performs action
        # participatory_process - participatory_process for action
        # initial_status - check consultation status of praticipatory process
        #
        def initialize(participatory_process, user)
          @current_user = user
          @participatory_process = participatory_process
          @initial_status = participatory_process.consultation_status
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if participatory process not published
        # - :no_report_added if no report added
        # - :report_notification_was_send if report notification has been already_send
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless participatory_process.published?
          return broadcast(:no_report_added) if no_report_added
          return broadcast(:report_notification_was_send) if report_notification_was_send

          send_notification_process_report
          broadcast(:ok)
        end

        private

        attr_reader :current_user, :participatory_process

        def report_notification_was_send
          participatory_process.report_notification_send
        end

        def no_report_added
          participatory_process.report_description.blank?
        end

        def send_notification_process_report
          Decidim.traceability.perform_action!(
            :send_notification_process_report,
            participatory_process,
            current_user
          ) do
            participatory_process.update(report_notification_send_date: Time.current, report_notification_send: true)

            Decidim::CoreExtended::TemplatedMailerJob.perform_later("report_published", { resource: participatory_process })
          end
        end
      end
    end
  end
end
