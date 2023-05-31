# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating a Hero Section.
    class UpdateHeroSection < Rectify::Command
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

      # zapisuje log jesli wczesniej niebylo obrazka, lub jesli zostal zmieniony
      def add_log_if_banner_img_changed(banner_img_id_before_change)
        return if banner_img_id_before_change.nil?

        add_log_banner_img(@hero_section) if !@hero_section.banner_img.attached? || banner_img_id_before_change != @hero_section.banner_img.id
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        banner_img_id_before_change = @hero_section.banner_img.id if @hero_section.banner_img.attached?
        return broadcast(:invalid) if form.invalid?

        update_hero_section
        add_log_if_banner_img_changed(banner_img_id_before_change)
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
          subtitle: form.subtitle,
          banner_img_alt: form.banner_img_alt
        }.tap { |attr| attr[:banner_img] = form.banner_img if form.banner_img }
      end

      def add_log_banner_img(hero_section)
        Decidim::ActionLogger.log(
          "update_banner_img",
          form.current_user,
          hero_section,
          hero_section.versions.last.id,
          { banner_img: form.banner_img }
        )
      end
    end
  end
end
