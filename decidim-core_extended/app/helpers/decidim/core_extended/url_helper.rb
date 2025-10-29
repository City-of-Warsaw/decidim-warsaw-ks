# frozen_string_literal: true

module Decidim
  module CoreExtended
    # Custom helper helps to work with URLs
    module UrlHelper
      def links_to_files_array(file_or_files)
        Array.wrap(file_or_files).map do |file|
          Rails.application.routes.url_helpers.rails_blob_url(file, host: current_organization.host)
        end
      end

      def static_page_with_rodo
        page_path('rodo') if Decidim::StaticPage.exists?(slug: "rodo")
      end

      def decidim_core_extended
        Decidim::CoreExtended::Engine.routes.url_helpers
      end
    end
  end
end
