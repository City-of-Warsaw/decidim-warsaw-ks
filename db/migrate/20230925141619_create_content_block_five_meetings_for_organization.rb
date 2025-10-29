class CreateContentBlockFiveMeetingsForOrganization < ActiveRecord::Migration[5.2]
  def change
    organization = Decidim::Organization.first
    if organization
      create_content_block_five_meetings_for_organization(organization)
    end
  end

  def create_content_block_five_meetings_for_organization(organization)
    return if Decidim::ContentBlock.where(decidim_organization_id: organization.id).find_by(manifest_name: 'five_meetings')
    return unless Decidim.content_blocks.for(:homepage).select(&:default).map(&:name).include?(:five_meetings)

    # The lack of :published_at && :weight indicates, that once this content block is created, it will be inactive
    Decidim::ContentBlock.create!(
      decidim_organization_id: organization.id,
      scope_name: :homepage,
      manifest_name: 'five_meetings'
    )
  end
end
