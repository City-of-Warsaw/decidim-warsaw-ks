# frozen_string_literal: true

module Decidim
  module News
    module Admin
      # A command with all the business logic to destroy Information
      class DestroyInformation < Decidim::Command
        # Public: Initializes the command.
        #
        # information - The Information to destroy
        def initialize(information)
          @information = information
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if no information and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless information

          destroy_information!

          broadcast(:ok)
        end

        private

        attr_reader :information

        def destroy_information!
          Decidim.traceability.perform_action!(
            :delete,
            information,
            current_user
          ) do
            information.destroy!
          end
        end
      end
    end
  end
end
