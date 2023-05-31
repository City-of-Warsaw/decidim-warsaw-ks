# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating an main_menu_item.
    class UpdateMainMenuItem < Rectify::Command
      # Public: Initializes the command.
      #
      # main_menu_item - The MainMenuItem to update
      # form - A form object with the params.
      def initialize(main_menu_item, form)
        @main_menu_item = main_menu_item
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

        update_main_menu_item
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_main_menu_item
        Decidim.traceability.update!(
          @main_menu_item,
          form.current_user,
          attributes
        )
      end

      def attributes
        {
          name: form.name,
          weight: form.weight,
          visible: form.visible
        }
      end
    end
  end
end
