# frozen_string_literal: true

module Decidim
  module News
    # This cell renders the Grid (:g) card
    class InformationGCell < Decidim::CardGCell
      include Decidim::News::UrlHelper

      def len
        @options[:length] || 200
      end

      private

      def description
        text = model.body

        decidim_sanitize(html_truncate(strip_links(text), length: len))
      end

      def ending_date
        return '' unless model.added_on

        l(model.added_on, format: :decidim_short_cut_zero)
      end

      def has_image?
        false
      end

      def resource_path
        decidim_news.news_path(model)
      end
    end
  end
end
