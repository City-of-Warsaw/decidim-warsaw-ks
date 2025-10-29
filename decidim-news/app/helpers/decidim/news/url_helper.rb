# frozen_string_literal: true

module Decidim
  module News
    # Custom helper helps to work with News paths
    module UrlHelper
      def decidim_news
        Decidim::News::Engine.routes.url_helpers
      end
    end
  end
end
