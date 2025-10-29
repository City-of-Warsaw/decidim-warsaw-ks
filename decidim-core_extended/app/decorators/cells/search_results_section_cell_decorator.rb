# frozen_string_literal: true

Decidim::SearchResultsSectionCell.class_eval do
  # overwritten method
  # use our view
  # for process result change card
  # for comment result change card
  # for the rest change length
  def show
    render :show_new
  end
end
