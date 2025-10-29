# frozen_string_literal: true

Decidim::Admin::StaticPageForm.class_eval do
  include Decidim::Repository::Admin::GalleryInputAttributes
  include Decidim::Repository::Admin::GalleriesValidations

  attribute :show_on_help_page, Decidim::AttributeObject::TypeMap::Boolean
  attribute :show_in_footer, Decidim::AttributeObject::TypeMap::Boolean

  def map_model(model)
    super
    self.gallery_id = model.gallery_id
  end

end
