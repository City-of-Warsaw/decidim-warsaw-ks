# frozen_string_literal: true

Decidim::ContentBlocks::ParticipatorySpaceHeroSettingsFormCell.class_eval do
  # overwritten method - view
  # add image_alt to settings
  def show
    render :show_new
  end
end
