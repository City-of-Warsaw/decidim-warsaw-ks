class GenerateNewContextualHelpSections < ActiveRecord::Migration[5.2]
  def change
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
