# frozen_string_literal: true

# OVERWRITTEN DECIDIM COMMAND
# An update object used to update the StaticPage
# Class has been provided with attributes for adding more data to the object
Decidim::Admin::UpdateStaticPage.class_eval do

  private

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
      # gallery id - allows to choose gallery to show
      # show_on_help_page - allows to choose if object should be visible in help pages
      gallery_id: form.gallery_id,
      show_on_help_page: form.show_on_help_page
    }
  end
end