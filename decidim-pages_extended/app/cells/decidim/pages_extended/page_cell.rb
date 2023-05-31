# frozen_string_literal: true

module Decidim
  module PagesExtended
    # This cell renders the card for an instance of a page
    # the default size is the Medium Card (:m)
    class PageCell < Decidim::ViewModel
      
      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/pages_extended/page_m"
      end
    end
  end
end
