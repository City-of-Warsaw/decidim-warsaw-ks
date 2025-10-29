class RestoreOgDecidimHelpSectionPlusRemoveRedudantAssembliesFromIt < ActiveRecord::Migration[7.0]
  def change
    redudant_sections_ids = %w(
      assemblies
      consultation_requests
      ad_help_pages
      help_pages
    )

    Decidim::ContextualHelpSection.where(section_id: redudant_sections_ids).find_each(&:destroy)
  end
end
