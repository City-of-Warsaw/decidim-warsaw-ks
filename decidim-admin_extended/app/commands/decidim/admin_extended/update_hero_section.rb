# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating a Hero Section.
    class UpdateHeroSection < Decidim::Command
      # Public: Initializes the command.
      #
      # hero_section - The Hero Section to update
      # form - A form object with the params.
      # user - A user that performs action
      def initialize(hero_section, form, user)
        @hero_section = hero_section
        @form = form
        @current_user = user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_hero_section
        broadcast(:ok)
      end

      private

      attr_reader :form, :current_user

      # Private: updating hero section
      #
      # Method creates ActionLog
      #
      # Returns: Hero Section
      def update_hero_section
        Decidim.traceability.update!(
          @hero_section,
          current_user,
          attributes
        )
      end

      # Private: Hash of hero section attributes
      def attributes
        {
          title: form.title,
          description: form.description,
        }
      end
    end
  end
end
