# frozen_string_literal: true

module Decidim
  module PagesExtended
    # A cell to display a single page.
    # warning! this cell handle with component's object Decidim::Pages::Page AND also Decidim::StaticPage
    class PageCell < Decidim::ViewModel
      
      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/pages_extended/page_s"
      end
    end
  end
end
