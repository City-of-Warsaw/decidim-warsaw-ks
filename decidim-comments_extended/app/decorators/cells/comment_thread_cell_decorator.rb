# frozen_string_literal: true

Decidim::Comments::CommentThreadCell.class_eval do
  def show
    render :show_new
  end

  # overwritten method
  # expand method
  def author_name
    return t("decidim.components.comment.deleted_user") if model.author.deleted?
    return t("decidim.components.comment.blocked_user") && t("decidim.comments_extended.thread_signatures.blocked_user") if model.author.blocked?
    return t("decidim.comments_extended.thread_signatures.unregistered") if model.author.is_a?(Decidim::CommentsExtended::UnregisteredAuthor)
    return t("decidim.comments_extended.thread_signatures.official") if model.author.is_a?(Decidim::Organization)
    return t("decidim.comments_extended.thread_signatures.official") if model.author.is_a?(Decidim::User) && model.author.has_ad_role?

    model.author.name
  end

  def for_reader
    @options[:for_reader]
  end

  def title_hidden?
    true
  end
end
