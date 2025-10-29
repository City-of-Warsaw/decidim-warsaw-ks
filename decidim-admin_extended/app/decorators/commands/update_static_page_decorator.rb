# frozen_string_literal: true

# OVERWRITTEN DECIDIM COMMAND
# An update object used to update the StaticPage
# Class has been provided with attributes for adding more data to the object
Decidim::Admin::UpdateStaticPage.class_eval do
  include Decidim::Repository::Admin::GalleriesHelper

  # overwritten method
  # added methods when creating a new gallery
  def call
    return broadcast(:invalid) if form.invalid?

    update_resource
    resource.update_organization_tos_version if form.changed_notably
    add_gallery(@resource)

    broadcast(:ok)
  end

  private

  # overwritten method
  def attributes
    {
      title: form.title,
      slug: form.slug,
      show_in_footer: form.show_in_footer,
      weight: form.weight,
      topic: form.topic,
      content: form.content,
      allow_public_access: form.allow_public_access,
      # added custom attributes:
      gallery_id: form.gallery_id,
      show_on_help_page: form.show_on_help_page
    }
  end
end
