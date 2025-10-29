# frozen_string_literal: true
# Overwritten whole extension helper Decidim::FlashHelperExtensions, because concerns doesn't eval privates methods.


require "active_support/concern"
module Decidim
  module FlashHelperExtensions
    extend ActiveSupport::Concern
    included do
      SIMPLIFIED_KEY_MATCHING = {
         alert: :alert,
          notice: :success,
          notice_html: :success,
          info: :success,
          secondary: :success,
          success: :success,
          error: :alert,
          warning: :alert,
          primary: :success
      }.freeze

      def display_flash_messages(closable: true, key_matching: {})
        key_matching = FoundationRailsHelper::FlashHelper::DEFAULT_KEY_MATCHING.merge(key_matching)
        key_matching.default = :primary

        capture do
          flash.each do |key, value|
            next if ignored_key?(key.to_sym)

            alert_class = key_matching[key.to_sym]
            concat over_alert_box(value.try(:html_safe), alert_class, closable)
          end
        end
      end
      private

      def over_alert_box(value, alert_class, closable, opts = {})
        options = {
          class: "flash #{alert_class}",
          data: { "alert-box": "" },
          role: "alert",
          aria: { atomic: "true" }
        }.merge(opts)

        options[:data] = options[:data].merge(closable: "") if closable
        content_tag(:div, options) do
          concat over_flash_icon(alert_class)
          concat message(value)
          concat close_link if closable
        end
      end

      # Icon with wrapper class
      #
      # @private
      #
      # @param alert_class [String] - The foundation class of the alert message.
      #
      # @return [String] the HTML with the icon
      def over_flash_icon(alert_class)
        image_pack_tag("media/images/flash-#{SIMPLIFIED_KEY_MATCHING[alert_class.to_sym]}.png", alt: '')
      end
      def close_link
        button_tag(
          class: "close-button",
          type: "button",
          data: { close: "" },
          aria: { label: I18n.t("decidim.alert.dismiss") }
        ) do
          icon "close-line"
        end
      end

      def message(value)
        return content_tag(:div, value, class: "flash__message flex items-center") unless value.is_a?(Hash)

        content_tag(:div, class: "flash__message") do
          concat value[:title]
          concat content_tag(:span, value[:body], class: "flash__message-body")
        end
      end
    end
  end
end
