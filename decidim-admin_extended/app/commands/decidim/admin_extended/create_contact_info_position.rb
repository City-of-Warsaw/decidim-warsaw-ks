# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a Contact Info Position
    class CreateContactInfoPosition < Rectify::Command
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

        create_contact_info_position
        broadcast(:ok)
      end

      private

      attr_reader :form

      # Private method
      #
      # Creates contact info position
      def create_contact_info_position
        @contact_info_position = Decidim::AdminExtended::ContactInfoPosition.create(attributes)
      end

      # Private: attributes for contact info position
      #
      # Returns Hash
      def attributes
        {
          name: form.name,
          position: form.position,
          phone: form.phone,
          email: form.email,
          published: form.published,
          weight: form.weight,
          contact_info_group_id: form.contact_info_group_id
        }
      end
    end
  end
end
