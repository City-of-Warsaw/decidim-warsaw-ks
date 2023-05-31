# frozen_string_literal: true

# OVERWRITTEN DECIDIM MODEL
# Model has been expanded with:
# - associations: to gallery
# - validation
# - searchable
Decidim::Pages::Page.class_eval do
  include Decidim::Publicable
  include Decidim::Searchable

  belongs_to :gallery, class_name: "Decidim::Repository::Gallery", optional: true

  translatable_fields :title
  validates :title, presence: true

  searchable_fields({
                      participatory_space: { component: :participatory_space },
                      A: :title,
                      D: :body,
                      datetime: :created_at
                    },
                      index_on_create: ->(page) { page.visible? },
                      index_on_update: ->(page) { page.visible? })

  def title
    read_attribute(:title)
  end

  def participatory_space
    component.participatory_space
  end

  def slug
    id
  end

  def content
    body
  end

  def visible?
    published?
  end
end
