# frozen_string_literal: true

module Decidim
  module News
    # This cell renders the Medium (:m) post card
    # for an given instance of a Post
    class InformationMCell < Decidim::CardMCell
      include Rails.application.routes.mounted_helpers

      def resource_path
        decidim_news.news_path(model)
      end

      def column_size_classes
        options[:column_size_classes]
      end

      def len
        @options[:length] || 100
      end

      private

      def description
        text = model.body

        decidim_sanitize(html_truncate(text, length: len))
      end

      def creation_date
        l(model.created_at.to_date, format: :decidim_short)
      end

      # used for displaying coauthorship in author cell, and for voting and other actions
      def has_actions?
        false
      end
    end
  end
end
