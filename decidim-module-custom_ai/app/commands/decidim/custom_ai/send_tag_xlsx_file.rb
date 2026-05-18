# frozen_string_literal: true

module Decidim
  module CustomAi
    # A command with all the business logic when uploading file XLSX to AI module.
    class SendTagXlsxFile < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # file - A object with AI files.
      def initialize(form, file)
        @form = form
        @file = file
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        if broadcast_file_to_ai(@form.file)
          create_log_about_answers_ai_decision_update
          broadcast(:ok)
        else
          broadcast(:invalid)
        end
      end

      private

      attr_reader :form

      # Private: creating tag
      #
      # Method creates ActionLog
      #
      # Returns: file

      def broadcast_file_to_ai(file)
        params = {
          "file_base64": Base64.encode64(file.tempfile.read),
          "file_name": file.original_filename,
          "component_id": current_component.id,
        }
        file_api = Decidim::CustomAi::AiApi.new("add_decisions_file", params).fetch

        unless file_api[:error].nil?
          puts "Blad przetwarzania odpowiedzi add_decisions_file dla pliku XLSX - dopowiedz AI: #{file_api[:error]}"
          Sentry.capture_message("Blad przetwarzania odpowiedzi add_decisions_file dla pliku XLSX - dopowiedz AI: #{file_api[:error]}") unless file_api[:error].nil?
          return false
        end

        true
      end

      def create_log_about_answers_ai_decision_update
        Decidim.traceability.perform_action!(
          :send_xlsx_file_to_ai_module,
          # only for component and log create purposes we using files from component
          @file,
          @form.current_user,
          log_info(@form.current_component)
        )
      end

      def log_info(component)
        {
          participatory_space: {
            title: component.participatory_space.title,
            manifest_name: "participatory_processes"
          },
          component: {
            title: component.name,
            manifest_name: component.manifest_name
          },
          visibility: "admin-only"
        }
      end

    end
  end
end
