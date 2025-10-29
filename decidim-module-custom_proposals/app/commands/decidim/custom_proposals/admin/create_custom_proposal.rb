# frozen_string_literal: true

module Decidim
  module CustomProposals
    # A command with all the business logic when creating a Custom Proposal
    class Admin::CreateCustomProposal < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
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

        create_custom_proposal
        broadcast(:ok)
      end

      private

      attr_reader :form

      # Private method
      #
      # Creates custom proposal
      def create_custom_proposal
        @custom_proposal = Decidim.traceability.create!(
          Decidim::CustomProposals::CustomProposal,
          form.current_user,
          attributes,
          visibility: "admin-only"
        )
      end

      # Private: attributes for custom_proposal
      #
      # Returns Hash
      def attributes
        {
          title: form.title,
          body: form.body,
          published: form.published,
          weight: form.weight,
          component: form.current_component
        }
      end
    end
  end
end
