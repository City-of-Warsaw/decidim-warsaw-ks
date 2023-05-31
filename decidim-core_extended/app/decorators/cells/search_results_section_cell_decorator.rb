# frozen_string_literal: true

Decidim::SearchResultsSectionCell.class_eval do
  def filter_scopes_values
    Decidim::Scope.all.map do |el|
      [translated_attribute(el.name), el.id]
    end
  end

  def decidim_comments_extended
    Decidim::CommentsExtended::Engine.routes.url_helpers
  end
  
  def show
    render :show_new
  end
end