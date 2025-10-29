# frozen_string_literal: true

Decidim::NavLinksCell.class_eval do
  # overwritten method - view:
  # move here:
  # - old right column
  # - old timeline
  def show
    render :show_new
  end
end
