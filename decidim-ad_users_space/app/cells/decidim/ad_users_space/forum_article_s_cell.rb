# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    # This cell renders the Show (:s) post card
    # for an given instance of a Forum Article
    class ForumArticleSCell < ForumArticleMCell

      private

      def comments_present?
        model.comments_count > 0
      end

      def description
        decidim_sanitize(model.body)
      end
    end
  end
end
