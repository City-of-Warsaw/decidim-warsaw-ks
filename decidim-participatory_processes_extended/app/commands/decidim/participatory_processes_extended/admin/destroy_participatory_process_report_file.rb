# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A command with all the business logic to update report for participatory process
      class DestroyParticipatoryProcessReportFile < Decidim::Command
        # Public: Initializes the command.
        #
        # report_file - Report file data
        # user - A user that performs action
        def initialize(report_file, user)
          @current_user = user
          @report_file = report_file
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          destroy_participatory_process_report_file
          broadcast(:ok)
        end

        private

        attr_reader :current_user, :report_file

        def destroy_participatory_process_report_file
          Decidim.traceability.perform_action!(
            :delete,
            report_file,
            current_user
          ) do
            report_file.destroy
          end
        end
      end
    end
  end
end
