# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class TwoPartBlockInfoCell < Decidim::ViewModel
      include Decidim::CardHelper

      def show
        render :show
      end

      private

      def left_title
        model.settings.left_title
      end

      def left_description
        model.settings.left_description
      end

      def left_block_url
        model.settings.left_block_url
      end

      def right_title
        model.settings.right_title
      end

      def right_description
        model.settings.right_description
      end

      def right_block_url
        model.settings.right_block_url
      end

      # Decidim Content block does not validate showing it on homepage.
      # In result content block can be activated with nil form fields.
      # If one of those fields is a link to another space, then it should be subjected to the condition
      def blocks_urls_not_nil?
        !left_block_url.nil? && !right_block_url.nil?
      end
    end
  end
end
