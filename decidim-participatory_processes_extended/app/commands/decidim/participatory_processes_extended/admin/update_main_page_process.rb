# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A command with all the business logic when selecting process for existing main page process
      class UpdateMainPageProcess < Rectify::Command
        # Public: Initializes the command.
        #
        # main_page_process - The Main Page Process to update
        # form - A form object with the params.
        # user - A user that performs action
        # action - symbol for action log, possible values: :add_process_to_main_page, :update_main_page_process
        def initialize(main_page_process, form, user, action)
          @main_page_process = main_page_process
          @form = form
          @current_user = user
          @action = action
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_main_page_process
          broadcast(:ok)
        end

        private

        attr_reader :form, :current_user

        # Private: selecting process for existing main page process
        #
        # Method creates ActionLog
        #
        # Returns: Main Page Process
        def update_main_page_process
          Decidim.traceability.perform_action!(
            @action,
            @main_page_process,
            current_user
          ) do
            main_page_process.update(attributes)
          end
        end

        # Private: Hash of main page process attributes
        def attributes
          {
            show_on_main_page: true,
            main_page_weight: form.weight
          }
        end
      end
    end
  end
end 
