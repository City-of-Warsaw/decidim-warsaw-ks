# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class TwoPartBlockInfoSettingsFormCell < Decidim::ViewModel
      alias form model

      def content_block
        options[:content_block]
      end

      def show
        render :show
      end
    end
  end
end
