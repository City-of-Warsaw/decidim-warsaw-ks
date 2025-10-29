# frozen_string_literal: true

Decidim::AnnouncementCell.class_eval do
  # overwritten method-view
  # use our view
  def show
    return if blank_content?

    render :show_new
  end
end

