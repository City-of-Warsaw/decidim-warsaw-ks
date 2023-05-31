# frozen_string_literal: true

module Decidim
  module PagesExtended
    # This cell renders the Medium (:m) page card
    # for an given instance of a page
    class PageMCell < Decidim::CardMCell

      def show
        render :show_new
      end

      private

      def has_actions?
        false
      end
    end
  end
end
