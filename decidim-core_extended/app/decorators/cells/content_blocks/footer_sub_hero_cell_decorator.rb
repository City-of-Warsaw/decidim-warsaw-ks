# frozen_string_literal: true

Decidim::ContentBlocks::FooterSubHeroCell.class_eval do
  def show
    render :show_new
  end
end
