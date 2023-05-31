# frozen_string_literal: true

# OVERWRITTEN DECIDIM MODEL
# Model has been expanded with:
# association: parent to see static pages in particular gallery.
# searchable fields
Decidim::StaticPage.class_eval do
  include Decidim::Searchable
  
  belongs_to :gallery, class_name: "Decidim::Repository::Gallery", optional: true

  scope :for_help_pages, -> { where(show_on_help_page: true) }

  searchable_fields({
                      organization_id: :decidim_organization_id,
                      participatory_space: :itself,
                      A: :title,
                      D: :content,
                      datetime: :created_at
                    },
                    index_on_create: ->(static_page) { static_page.visible? },
                    index_on_update: ->(static_page) { static_page.visible? })
  
  def visible?
    show_on_help_page?
  end
end
