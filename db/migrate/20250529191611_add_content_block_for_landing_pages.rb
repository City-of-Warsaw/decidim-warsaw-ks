class AddContentBlockForLandingPages < ActiveRecord::Migration[7.0]
  # Migration only for prepare existing participatory processes 'home page' after migration from older versions
  def up
    Decidim::ParticipatoryProcess.all.each do |process|
      block = Decidim::ContentBlock.find_or_create_by(
        organization: process.organization,
        scope_name: "participatory_process_homepage",
        scoped_resource_id: process.id,
        manifest_name: "hero",
        weight: 1
      )
      if block && process.hero_image&.attached?
        block.images_container.background_image.attach(process.hero_image.blob)
      end
      block.update(published_at: Time.current)

      main_data = Decidim::ContentBlock.find_or_create_by!(
        organization: process.organization,
        scope_name: "participatory_process_homepage",
        scoped_resource_id: process.id,
        manifest_name: "main_data",
        weight: 2
      )
      main_data.update(published_at: Time.current)

      area_map = Decidim::ContentBlock.find_or_create_by!(
        organization: process.organization,
        scope_name: "participatory_process_homepage",
        scoped_resource_id: process.id,
        manifest_name: "area_map",
        weight: 3
      )
      area_map.update(published_at: Time.current)

      metadata = Decidim::ContentBlock.find_or_create_by!(
        organization: process.organization,
        scope_name: "participatory_process_homepage",
        scoped_resource_id: process.id,
        manifest_name: "metadata",
        weight: 4,
      )
      metadata.update(published_at: Time.current)

      related_images = Decidim::ContentBlock.find_or_create_by!(
        organization: process.organization,
        scope_name: "participatory_process_homepage",
        scoped_resource_id: process.id,
        manifest_name: "related_images",
        weight: 5
      )
      related_images.update(published_at: Time.current)

      related_documents = Decidim::ContentBlock.find_or_create_by!(
        organization: process.organization,
        scope_name: "participatory_process_homepage",
        scoped_resource_id: process.id,
        manifest_name: "related_documents",
        weight: 6
      )
      related_documents.update(published_at: Time.current)

      related_processes = Decidim::ContentBlock.find_or_create_by!(
        organization: process.organization,
        scope_name: "participatory_process_homepage",
        scoped_resource_id: process.id,
        manifest_name: "related_processes",
        weight: 7
      )
      related_processes.update(published_at: Time.current)

      Decidim::ContentBlock.find_or_create_by!(
        organization: process.organization,
        scope_name: "participatory_process_homepage",
        scoped_resource_id: process.id,
        manifest_name: "announcement",
        weight: 8
      )
    end
  end

  def down; end
end
