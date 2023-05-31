# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A command with all the business logic when selecting process for new main page process
      class DestroyMainPageProcess < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # user - A user that performs action
        def initialize(main_page_process, user)
          @main_page_process = main_page_process
          @current_user = user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        #
        # Returns nothing.
        def call
          destroy_main_page_process
          broadcast(:ok)
        end

        private

        attr_reader :main_page_process, :current_user

        # Private: destroying process for new main page process
        #
        # Returns: nothing
        def destroy_main_page_process
          Decidim.traceability.perform_action!(
            :destroy_main_page_process,
            main_page_process,
            current_user
          ) do
            main_page_process.update(attributes)
          end
        end

        def attributes
          {
            show_on_main_page: false,
            main_page_weight: 0 # setting default value
          }
        end
      end
    end
  end
end
