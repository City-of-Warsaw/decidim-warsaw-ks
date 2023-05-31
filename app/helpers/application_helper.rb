# frozen_string_literal: true

module ApplicationHelper
  def main_background_image
    Decidim::ContentBlock.where(decidim_organization_id: current_organization.id).find_by(manifest_name: 'hero').images_container.background_image.big.url
  end
end
