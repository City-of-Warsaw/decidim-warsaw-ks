# frozen_string_literal: true

module Decidim
  module News
    module Admin
      # This command is executed when user creates Information
      class DestroyInformation < Rectify::Command
        def initialize(information)
          @information = information
        end

        # Destroys the information if it exists.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
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
