# frozen_string_literal: true

# OVERWRITTEN DECIDIM COMMAND
# A create object used to create StaticPage
# Class has been provided with attributes for adding more data to the object
Decidim::Admin::CreateStaticPage.class_eval do

  private

  # OVERWRITTEN DECIDIM METHOD
  # now method assings data to attributes directly in this method
  # added custom attributes
  def create_page
    @page = Decidim.traceability.create!(
      Decidim::StaticPage,
      form.current_user,
      title: form.title,
      slug: form.slug,
      content: form.content,
      show_in_footer: form.show_in_footer,
      weight: form.weight,
      topic: form.topic,
      organization: form.organization,
      allow_public_access: form.allow_public_access,
      # added custom attributes:
      # gallery id - allows to choose parent
      # show_on_help_page - allows to choose if object should be visible in # TODO terminology for KS
      gallery_id: form.gallery_id,
      show_on_help_page: form.show_on_help_page
    )
  end
end