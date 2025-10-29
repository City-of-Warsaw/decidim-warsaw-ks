# frozen_string_literal: true

Decidim::PhotosListCell.class_eval do
  # overwritten method - view:
  # swap decidim photos with our gallery from module repository
  def show
    render :show_new
  end

  def render_gallery_partial
    ApplicationController.renderer.render(
      partial: "decidim/shared/gallery_attachments",
      locals: { model: current_participatory_space }
    )
  end
end
