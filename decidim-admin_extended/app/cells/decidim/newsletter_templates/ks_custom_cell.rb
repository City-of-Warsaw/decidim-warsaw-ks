# frozen_string_literal: true

require "cell/partial"

module Decidim
  module NewsletterTemplates
    class KsCustomCell < Decidim::NewsletterTemplates::BaseCell
      include Decidim::NewsletterTemplates::SharedTemplateMethods

      def show
        render :show
      end

      def encouragement
        parse_interpolations(uninterpolated_encouragement, recipient_user, newsletter.id)
      end

      def uninterpolated_encouragement
        translated_attribute(model.settings.encouragement)
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
    end
  end
end
