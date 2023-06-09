# frozen_string_literal: true

# TODO: needs refactor because its overwritten Decidim module

require "active_support/concern"

module Decidim
  module FlashHelperExtensions
    extend ActiveSupport::Concern

    included do
      private

      # Private: Foundation alert box.
      #
      # Overrides the foundation alert box helper for adding accessibility tags.
      #
      # value - The flash message.
      # alert_class - The foundation class of the alert message.
      # closable - A boolean indicating whether the close icon is added.
      #
      # Returns a HTML string.
      def alert_box(value, alert_class, closable)
        content_tag(:div, { class: "flash callout #{alert_class}", tabindex: -1, data: closable ? { closable: "" } : {} }) do
          concat value
          concat close_link if closable
        end
      end

      # Private: Foudation alert box close link.
      #
      # Overrides the foundation alert box close link helper for the aria-label
      # translations.
      def close_link
        button_tag(
          class: "close-button",
          type: "button",
          data: { close: "" },
          aria: { label: I18n.t("decidim.alert.dismiss") }
        ) do
          content_tag(:span, "&times;".html_safe, aria: { hidden: true })
        end
      end
    end
  end
end
