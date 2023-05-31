# frozen_string_literal: true

Decidim::Comments::CommentsHelper.module_eval do

  # Render commentable comments inside the `expanded` template content.
  # Adds sorting for comments
  #
  # resource - A commentable resource
  def sorted_comments_for(resource, options = {})
    return unless resource.commentable?

    options[:order] = "recent" if options[:order].blank?
    content_for :expanded do
      inline_comments_for(resource, options)
    end
  end

end
