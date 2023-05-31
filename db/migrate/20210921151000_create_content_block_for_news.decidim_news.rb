# This migration comes from decidim_news (originally 20210921144023)
class CreateContentBlockForNews < ActiveRecord::Migration[5.2]
  def up
    rename_table :decidim_news_information, :decidim_news_informations

    Decidim::Organization.all.each { |organization| create_content_block_for_news(organization) }
  end

  def down
    rename_table :decidim_news_informations, :decidim_news_information
  end

  def create_content_block_for_news(organization)
    return if Decidim::ContentBlock.where(decidim_organization_id: organization.id).find_by(manifest_name: 'latest_informations') # skip if already created
    return unless Decidim.content_blocks.for(:homepage).select(&:default).map(&:name).include?(:latest_informations) # needs to be included in an engine

    Decidim::ContentBlock.create!(
      decidim_organization_id: organization.id,
      weight: 90,
      scope_name: :homepage,
      manifest_name: 'latest_informations',
      published_at: Time.current
    )
  end
end
