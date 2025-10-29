# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A command with all the business logic to update report file for participatory process
      class UpdateParticipatoryProcessReportFile < Decidim::Command
        # Public: Initializes the command.
        #
        # main_page_process - The Main Page Process to update
        # form - A form object with the params.
        # user - A user that performs action
        def initialize(form, user)
          @form = form
          @current_user = user
          @report_file = form.reported_file
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_participatory_process_report_file
          broadcast(:ok)
        end

        private

        attr_reader :form, :current_user, :report_file

        def update_participatory_process_report_file
          Decidim.traceability.perform_action!(
            :update,
            report_file,
            current_user
          ) do
            report_file.update(attributes)
          end
        end

        # Private: Hash of participatory process file attributes

        def attributes
          {
            name: form.name,
            published: form.published,
            weight: form.weight
          }.merge(file_data)
        end

        #If new file added - replace it
        def file_data
          if form.file.present?
            { file: form.file }
          else
            {}
          end
        end
      end
    end
  end
end
