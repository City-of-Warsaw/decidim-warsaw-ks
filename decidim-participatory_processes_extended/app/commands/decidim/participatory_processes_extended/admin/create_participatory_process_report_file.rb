# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A command with all the business logic to create report file for participatory process
      class CreateParticipatoryProcessReportFile < Decidim::Command
        # Public: Initializes the command.
        #
        # main_page_process - The Main Page Process to update
        # form - A form object with the params.
        # user - A user that performs action.
        # participatory_process - participatory_process for action.
        #
        def initialize(form, user, participatory_process)
          @form = form
          @participatory_process = participatory_process
          @current_user = user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          create_participatory_process_report_file
          broadcast(:ok)
        end

        private

        attr_reader :form, :current_user, :participatory_process

        def create_participatory_process_report_file
          Decidim.traceability.create!(
            Decidim::ParticipatoryProcessesExtended::ParticipatoryProcessReportFile,
            current_user,
            report_file_params
          )
        end

        # Private: Hash of participatory process file attributes

        def report_file_params
          {
            name: form.name,
            published: form.published,
            weight: form.weight,
            file: form.file,
            decidim_participatory_process_id: participatory_process.id
          }
        end
      end
    end
  end
end
