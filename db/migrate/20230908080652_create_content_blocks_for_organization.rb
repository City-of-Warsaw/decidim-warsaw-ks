class CreateContentBlocksForOrganization < ActiveRecord::Migration[5.2]
  def change
    organization = Decidim::Organization.first
    if organization
      create_content_blocks_for_organization(organization)
    end
  end

  def create_content_blocks_for_organization(organization)
    return if Decidim::ContentBlock.where(decidim_organization_id: organization.id).find_by(manifest_name: 'register_user')
    return unless Decidim.content_blocks.for(:homepage).select(&:default).map(&:name).include?(:register_user)

    # The lack of :published_at && :weight indicates, that once this content block is created, it will be inactive
    Decidim::ContentBlock.create!(
      decidim_organization_id: organization.id,
      scope_name: :homepage,
      manifest_name: 'register_user'
    )

    return if Decidim::ContentBlock.where(decidim_organization_id: organization.id).find_by(manifest_name: 'two_part_block_info')
    return unless Decidim.content_blocks.for(:homepage).select(&:default).map(&:name).include?(:two_part_block_info)

    # The lack of :published_at && :weight indicates, that once this content block is created, it will be inactive
    Decidim::ContentBlock.create!(
      decidim_organization_id: organization.id,
      scope_name: :homepage,
      manifest_name: 'two_part_block_info'
    )
  end
end
