# frozen_string_literal: true

Decidim::Pages::Admin::UpdatePage.class_eval do
  include Decidim::PagesExtended::ApplicationHelper

  private

  def update_page
    Decidim.traceability.update!(
      @page,
      @form.current_user,
      body: @form.body,
      title: @form.title,
      gallery_id: @form.gallery_id
    )
  end
end
