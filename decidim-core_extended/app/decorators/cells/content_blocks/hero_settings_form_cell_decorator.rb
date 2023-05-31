# frozen_string_literal: true

Decidim::ContentBlocks::HeroSettingsFormCell.class_eval do
  def show
    render :show_new
  end
end
