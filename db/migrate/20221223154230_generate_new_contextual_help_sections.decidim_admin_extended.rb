# This migration comes from decidim_admin_extended (originally 20221223153940)
class GenerateNewContextualHelpSections < ActiveRecord::Migration[5.2]
  def change
    unless Decidim::Organization.first.nil?
    ['consultation_requests', "ad_help_pages", 'help_pages'].each do |el|
      Decidim::ContextualHelpSection.find_or_create_by({
                                              section_id: el,
                                              organization_id: Decidim::Organization.first.id,
                                              content: {
                                                'en': '',
                                                'pl': ''
                                              }
                                            })
    end
    end
  end
end
