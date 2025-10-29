# frozen_string_literal: true

module Decidim
  module News
    module Admin
      # A command with all the business logic to unpublish Information in public view
      class UnpublishInformation < Decidim::Command
        # Public: Initializes the command.
        #
        # information - The Information to unpublished
        def initialize(information)
          @information = information
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        #
        # Returns nothing.
        def call
          unpublish_information!

          broadcast(:ok)
        end

        private

        attr_reader :information

        def unpublish_information!
          Decidim.traceability.perform_action!(
            :unpublish,
            information,
            current_user,
            visibility: 'admin-only'
          ) do
            information.update(published: false)
            information
          end
        end
      end
    end
  end
end
