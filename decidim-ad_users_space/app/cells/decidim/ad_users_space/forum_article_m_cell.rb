# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    # This cell renders the Medium (:m) post card
    # for an given instance of a Forum Article
    class ForumArticleMCell < Decidim::CardMCell
      include Rails.application.routes.mounted_helpers

      def resource_path
        decidim_ad_users_space.forum_article_path(model)
      end

      def column_size_classes
        options[:column_size_classes]
      end

      def author
        render :author
      end

      private

      def author_name
        model.author ? model.author.name : t("decidim.ad_users_space.forum_article_m.official_author")
      end

      def comments_present?
        model.comments_count > 0
      end

      def last_comment
        model.comments.order(updated_at: :asc).first
      end

      def comment_author
        last_comment.author.name
      end

      def comment_date
        l last_comment.updated_at, format: :decidim_short
      end

      def comment_text
        html_truncate(last_comment.body['pl'], length: 25)
      end

      def description
        text = model.body

        decidim_sanitize(html_truncate(text, length: 50))
      end

      def avatar_url
        if model.author && model.author.avatar
          model.author.avatar.url
        else
          ActionController::Base.helpers.asset_path("decidim/default-avatar.svg")
        end
      end

      # TODO: change when attachmants are added
      def has_image?
        false
      end

      # used for displaying coauthorship in author cell, and for voting and other actions
      def has_actions?
        false
      end
    end
  end
end
