# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    # Service that encapsulates all logic related to filtering participatory processes.
    class ForumArticleSearch < Searchlight::Search

      def initialize(organization, raw_options = {})
        super(raw_options)
        @organization = organization
      end

      def base_query
        ForumArticle.where(decidim_organization_id: @organization.id).latest_first
      end

      def search_text
        query.left_outer_joins(:comments)
             .where("decidim_ad_users_space_forum_articles.body ILIKE :q OR \
                     decidim_ad_users_space_forum_articles.title ILIKE :q OR \
                     decidim_comments_comments.body->>'pl' ILIKE :q", q: "%#{text}%").distinct
      end
    end
  end
end
