# frozen_string_literal: true

module Decidim
  module News
    module Admin
      # A command with all the business logic to publish Information in public view
      class PublishInformation < Decidim::Command
        # Public: Initializes the command.
        #
        # information - The Information to publish
        def initialize(information)
          @information = information
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        #
        # Returns nothing.
        def call
          publish_information!

          broadcast(:ok)
        end

        private

        attr_reader :information

        def publish_information!
          Decidim.traceability.perform_action!(
            :publish,
            information,
            current_user,
            visibility: "admin-only"
          ) do
            information.update(published: true)
            information
          end
        end
      end
    end
  end
end
