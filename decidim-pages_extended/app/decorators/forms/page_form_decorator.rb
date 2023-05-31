# frozen_string_literal: true

Decidim::Pages::Admin::PageForm.class_eval do
  attribute :gallery_id, Integer

  translatable_attribute :title, String

  validates :title, translatable_presence: true

end
