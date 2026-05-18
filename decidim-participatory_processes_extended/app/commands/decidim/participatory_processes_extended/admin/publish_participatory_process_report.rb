# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A command with all the business logic to publish report for participatory process
      class PublishParticipatoryProcessReport < Decidim::Command
        # Public: Initializes the command.
        #
        # user - A user that performs action
        # participatory_process - participatory_process for action
        def initialize(participatory_process, user)
          @current_user = user
          @participatory_process = participatory_process
          @no_report_added = participatory_process.report_description.blank?
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:no_report_added) if @no_report_added

          publish_process_report
          broadcast(:ok)
        end

        private

        attr_reader :form, :current_user, :participatory_process

        def publish_process_report
          Decidim.traceability.perform_action!(
            :publish_participatory_process_report,
            participatory_process,
            current_user
          ) do
            participatory_process.update(report_published: true)
            participatory_process.set_consultation_status
          end
        end
      end
    end
  end
end
