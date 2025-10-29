# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A command with all the business logic to update report for participatory process
      class UpdateParticipatoryProcessReport < Decidim::Command
        # Public: Initializes the command.
        #
        # main_page_process - The Main Page Process to update
        # form - A form object with the params.
        # user - A user that performs action
        # participatory_process - participatory_process for action
        def initialize(form, user)
          @form = form
          @current_user = user
          @participatory_process = form.participatory_process
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_participatory_process_report
          broadcast(:ok)
        end

        private

        attr_reader :form, :current_user, :participatory_process

        def update_participatory_process_report
          Decidim.traceability.perform_action!(
            :update_praticipatory_process_report,
            participatory_process,
            current_user
          ) do
            participatory_process.update(attributes)
          end
        end

        # Private: Hash of main page process attributes

        def attributes
          {
            report_publication_date: form.report_publication_date,
            report_description: form.report_description
          }
        end
      end
    end
  end
end
