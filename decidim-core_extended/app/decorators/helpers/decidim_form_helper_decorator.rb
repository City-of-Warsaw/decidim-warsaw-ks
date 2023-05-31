# frozen_string_literal: true

Decidim::DecidimFormHelper.module_eval do
  # Find template for static page
  # Return string
  def page_template(page)
    return "decidim/pages/templates/standalone" unless page.topic
    return "decidim/pages/templates/tabbed" if page.topic.template.blank?

    "decidim/pages/templates/#{page.topic.template}"
  end

  # Returns static pages templates list
  # Return Array of String
  def page_templates
    # %w"faq contact costs info standalone"
    %w"contact"
  end

  # Returns templates list for StaticPageTopic select in form
  # Return Array of String
  def templates_collection_for_select
    page_templates.map{ |t| [t("decidim.admin.static_page_topics.templates.#{t}"), t] }
  end
end