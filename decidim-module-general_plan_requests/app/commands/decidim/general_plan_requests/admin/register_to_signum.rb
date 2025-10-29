# frozen_string_literal: true

module Decidim
  module GeneralPlanRequests
    module Admin
      # A command with all the business logic to register general plan requests into Signum at once.
      class RegisterToSignum < Decidim::Command
        include Decidim::EmailChecker

        # Public: Initializes the command.
        #
        # current_component    - The current component that contains the requests.
        # current_user         - the Decidim::User that is accepting changes.
        # general_plan_request - request to export into Signum
        # service              - Initialize the Class
        # urz_id               - for now - use the same that is used for study note
        def initialize(current_component, current_user, general_plan_request)
          @current_component = current_component
          @current_user = current_user
          @general_plan_request = general_plan_request
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :registered_already if the request was registered in Signum before.
        #
        # Returns nothing.
        def call
          return broadcast(:registered_already) if general_plan_request.registered_to_signum?

          register_to_signum

          broadcast(:ok, general_plan_request)
        end

        private

        attr_reader :current_component, :current_user, :general_plan_request

        def register_to_signum
          Decidim::SignumService.new.register_general_plan_request_to_signum(
            general_plan_request: general_plan_request,
            user: current_user
          )
        end
      end
    end
  end
end
