# frozen_string_literal: true

module Decidim
  module CustomProposals
    # A command with all the business logic when updating a Custom Proposal
    class Admin::UpdateCustomProposal < Decidim::Command
      # Public: Initializes the command.
      #
      # custom_proposal - A Custom Proposal to update.
      # form - A form object with the params.
      def initialize(custom_proposal, form)
        @custom_proposal = custom_proposal
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_custom_proposal
        broadcast(:ok, custom_proposal)
      end

      private

      attr_reader :form, :custom_proposal

      # Private method
      #
      # Updates custom proposal
      def update_custom_proposal
        Decidim.traceability.update!(
          custom_proposal,
          form.current_user,
          attributes,
          visibility: "admin-only"
        )
      end

      # Private: attributes for custom proposal
      #
      # Returns Hash
      def attributes
        {
          title: form.title,
          body: form.body,
          published: form.published,
          weight: form.weight
        }
      end
    end
  end
end
