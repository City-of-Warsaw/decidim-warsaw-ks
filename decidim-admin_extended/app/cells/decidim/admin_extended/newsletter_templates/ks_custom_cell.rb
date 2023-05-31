# frozen_string_literal: true

require "cell/partial"

module Decidim::AdminExtended
  module NewsletterTemplates
    class KsCustomCell < Decidim::NewsletterTemplates::BaseCell
      def show
        render :show
      end

      def title
        parse_interpolations(uninterpolated_title, recipient_user, newsletter.id)
      end

      def uninterpolated_title
        translated_attribute(model.settings.title)
      end

      def lead
        parse_interpolations(uninterpolated_lead, recipient_user, newsletter.id)
      end

      def uninterpolated_lead
        translated_attribute(model.settings.lead)
      end

      def encouragement
        parse_interpolations(uninterpolated_encouragement, recipient_user, newsletter.id)
      end

      def uninterpolated_encouragement
        translated_attribute(model.settings.encouragement)
      end

      def introduction
        parse_interpolations(uninterpolated_introduction, recipient_user, newsletter.id)
      end

      def uninterpolated_introduction
        translated_attribute(model.settings.introduction)
      end

      def body
        parse_interpolations(uninterpolated_body, recipient_user, newsletter.id)
      end

      def uninterpolated_body
        translated_attribute(model.settings.body)
      end

      def has_cta?
        cta_text.present? && cta_url.present?
      end

      def cta_text
        parse_interpolations(
          translated_attribute(model.settings.cta_text),
          recipient_user,
          newsletter.id
        )
      end

      def cta_url
        translated_attribute(model.settings.cta_url)
      end

      def has_main_image?
        main_image_url.present?
      end

      def main_image
        image_tag main_image_url
      end

      def main_image_url
        newsletter.template.images_container.main_image.url
      end

      def organization_primary_color
        organization.colors["primary"]
      end
    end
  end
end
