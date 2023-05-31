# frozen_string_literal: true

Decidim::Admin::HelpSectionsController.class_eval do
  private

  def sections
    @sections ||= ['consultation_requests', "ad_help_pages", 'help_pages'].map do |el|
                    OpenStruct.new(
                      id: el,
                      content: Decidim::ContextualHelpSection.find_content(current_organization, el)
                    )
                  end

  end
end
