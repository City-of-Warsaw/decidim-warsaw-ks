# frozen_string_literal: true

module Decidim::AdUsersSpace
  module ForumArticlesHelper
    def forum_article_comments_data(forum_article)
      { singleComment: true, rootDepth: 0, lastCommentId: forum_article.comments.latest_first.first&.id, order: "recent" }
    end

    def forum_article_node_id(forum_article)
      "comments-for-ForumArticle-#{forum_article.id}"
    end
  end
end
