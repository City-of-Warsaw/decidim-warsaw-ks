# frozen_string_literal: true

Decidim::Pages::Admin::UpdatePage.class_eval do
  include Decidim::PagesExtended::ApplicationHelper
  include Decidim::Repository::Admin::GalleriesHelper

  # overwritten method
  # added creating gallery
  def call
    return broadcast(:invalid) if @form.invalid?

    update_page
    add_gallery(@page)

    broadcast(:ok)
  end

  private

  def update_page
    Decidim.traceability.update!(
      @page,
      @form.current_user,
      body: @form.body,
      title: @form.title,
      weight: @form.weight,
      gallery_id: @form.gallery_id
    )
  end
end
