# frozen_string_literal: true

module Decidim
  module CustomProposals
    # A command with all the business logic when destroying a Custom Proposal
    class Admin::DestroyCustomProposal < Decidim::Command
      # Public: Initializes the command.
      #
      # custom_proposal - A Custom Proposal to destroy.
      def initialize(custom_proposal, current_user)
        @custom_proposal = custom_proposal
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        destroy_custom_proposal!
        broadcast(:ok)
      end

      private

      attr_reader :custom_proposal, :current_user

      def destroy_custom_proposal!
        Decidim.traceability.perform_action!(
          "delete",
          custom_proposal,
          current_user
        ) do
          custom_proposal.destroy!
        end
      end
    end
  end
end
