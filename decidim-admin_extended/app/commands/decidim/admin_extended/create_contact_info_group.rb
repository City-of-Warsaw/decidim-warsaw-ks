# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a Contact Info Group
    class CreateContactInfoGroup < Rectify::Command
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

        create_contact_info_group
        broadcast(:ok)
      end

      private

      attr_reader :form

      # Private method
      #
      # Creates contact info group
      def create_contact_info_group
        @contact_info_group = Decidim::AdminExtended::ContactInfoGroup.create(attributes)
      end

      # Private: attributes for contact info group
      #
      # Returns Hash
      def attributes
        {
          name: form.name,
          subtitle: form.subtitle,
          published: form.published,
          weight: form.weight
        }
      end
    end
  end
end
