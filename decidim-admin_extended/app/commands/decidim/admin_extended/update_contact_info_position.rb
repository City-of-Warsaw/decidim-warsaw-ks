# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating a Contact Info Position
    class UpdateContactInfoPosition < Rectify::Command
      # Public: Initializes the command.
      #
      # contact_info_position - A Contact Info Position to update.
      # form - A form object with the params.
      def initialize(contact_info_position, form)
        @contact_info_position = contact_info_position
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

        update_contact_info_position
        broadcast(:ok, contact_info_position)
      end

      private

      attr_reader :form

      # Private method
      #
      # Updates contact info position
      def update_contact_info_position
        @contact_info_position.update(attributes)
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
