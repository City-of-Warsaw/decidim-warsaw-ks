# frozen_string_literal: true

module Decidim
  module CustomAi
    module Admin
      # A command with all the business logic when accepting decidim forms answers
      class MarkAnswersAsAccepted < Decidim::Command
        # Public: Initializes the command.
        #
        # user - current user.
        # answers_ids - array of ids.
        def initialize(user, array_ids)
          @user = user
          @answers_ids = array_ids
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the collection blank and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if @answers_ids.blank?

          Decidim::CustomAi::MarkAnswersAsAcceptedJob.perform_later(@user, @answers_ids)
          broadcast(:ok)
        end
      end
    end
  end
end
