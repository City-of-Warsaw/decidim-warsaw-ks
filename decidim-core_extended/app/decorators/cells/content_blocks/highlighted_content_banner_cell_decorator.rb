# frozen_string_literal: true

Decidim::ContentBlocks::HighlightedContentBannerCell.class_eval do
  def show
    render :show_new
  end
end
