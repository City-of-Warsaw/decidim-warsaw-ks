# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A command with all the business logic to send notification of result for participatory process
      class SendNotificationForResult < Decidim::Command
        # Public: Initializes the command.
        #
        # user - A user that performs action
        # participatory_process - participatory_process for action
        # initial_status - check consultation status of praticipatory process
        # results - current participatory_process results
        def initialize(participatory_process, user, results)
          @current_user = user
          @participatory_process = participatory_process
          @initial_status = participatory_process.consultation_status
          @participatory_process_results = results
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:no_result_added) if no_result_added
          return broadcast(:result_notification_was_send) if all_results_notification_sent

          send_notification_result
          broadcast(:ok)
        end

        private

        attr_reader :current_user, :participatory_process, :participatory_process_results

        def all_results_notification_sent
          participatory_process_results.all? { |result| result.notification_send == true }
        end

        def no_result_added
          participatory_process_results.blank?
        end

        def send_notification_result
          Decidim.traceability.perform_action!(
            :send_notification_process_result,
            participatory_process,
            current_user
          ) do
            participatory_process_results.where(published: true).update_all(notification_send_date: Time.current, notification_send: true)

            Decidim::CoreExtended::TemplatedMailerJob.perform_later('notification_about_process_results', { resource: participatory_process } )
          end
        end
      end
    end
  end
end
