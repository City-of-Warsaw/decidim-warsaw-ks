# frozen_string_literal: true

Decidim::Pages::Admin::PageForm.class_eval do
  include Decidim::Repository::Admin::GalleryInputAttributes
  include Decidim::Repository::Admin::GalleriesValidations

  translatable_attribute :title, String
  attribute :weight, Integer

  validates :title, translatable_presence: true

  def map_model(model)
    super
    self.gallery_id = model.gallery_id
    self.weight = model.weight
  end

end
