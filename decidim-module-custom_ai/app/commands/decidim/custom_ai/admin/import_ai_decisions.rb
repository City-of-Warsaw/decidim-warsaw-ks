# frozen_string_literal: true

module Decidim
  module CustomAi
    module Admin
      # A command with all the business logic when updating ai decision decidim forms answers with import
      class ImportAiDecisions < Decidim::Command
        # Public: Initializes the command.
        #
        # user - current user.
        # form - A form object with the params.
        # asnwer - if no collection return invalid
        def initialize(user, form, collection)
          @user = user
          @form = form
          @answer = collection.first
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        #
        # Returns nothing.
        def call
          create_proxy_attachment
          Decidim::CustomAi::ImportAiDecisionsJob.perform_later(@user, @attachment.id)
          create_log(@answer, "decidim_forms_answers_import")
          broadcast(:ok)
        end

        private

        def create_proxy_attachment
          file = @form.xlsx_file
          filename = file.original_filename
          content_type = file.content_type || "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

          @attachment = Decidim::Attachment.new(
            attached_to: @answer.questionnaire,
            title: { "pl": filename },
            content_type:
          )

          @attachment.file.attach(
            io: ::File.open(file.path),
            filename:,
            content_type:
          )

          @attachment.save!
          @attachment
        end

        def create_log(resource, log_type)
          Decidim.traceability.perform_action!(
            log_type,
            resource,
            current_user,
            log_info(resource)
          )
        end

        def log_info(answer)
          {
            resource: {
              title: answer.body
            },
            participatory_space: {
              title: current_component.participatory_space.title,
              manifest_name: "participatory_processes"
            },
            component: {
              title: current_component.name,
              manifest_name: current_component.manifest_name
            },
            visibility: "admin-only"
          }
        end
      end
    end
  end
end
