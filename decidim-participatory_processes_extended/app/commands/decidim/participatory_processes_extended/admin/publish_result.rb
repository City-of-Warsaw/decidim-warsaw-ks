# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A command with all the business logic to update result
      class PublishResult < Decidim::Command
        # Public: Initializes the command.
        #
        # participatory_space - The participatory space that will hold the result
        # result - the Result to update
        # author - The user that initiates updating that Result
        def initialize(result, current_user, participatory_space)
          @result = result
          @author = current_user
          @participatory_space = participatory_space
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          publish_result!
          participatory_space.update(consultation_status: "effects")

          broadcast(:ok)
        end

        private

        attr_reader :participatory_space, :author, :result

        def publish_result!
          Decidim.traceability.perform_action!(
            :publish,
            result,
            author,
            visibility: "admin-only"
          ) do
            result.update(published: true)
            result
          end
        end
      end
    end
  end
end
