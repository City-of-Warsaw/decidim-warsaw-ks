# frozen_string_literal: true

module Decidim
  module CustomAi
    module Admin
      # A command with all the business logic when updating ai grouping - similar and incorrect answers
      class UpdateAiGrouping < Decidim::Command
        # Public: Initializes the command.
        #
        # user - current user.
        # form - A form object with the params.
        def initialize(user, component)
          @user = user
          @component = component
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        #
        # Returns nothing.
        def call
          Decidim::CustomAi::UpdateAiGroupingJob.perform_later(@user, @component)
          broadcast(:ok)
        end
      end
    end
  end
end
