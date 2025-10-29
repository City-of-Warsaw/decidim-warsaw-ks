# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    # This cell renders the card for an instance of a Forum Article
    # the default size is the Medium Card (:m)
    class ForumArticleCell < Decidim::ViewModel
      include Cell::ViewModel::Partial

      def show
        cell card_size, model, options
      end

      private

      def card_size
        if options[:size] == :search
          "decidim/ad_users_space/forum_article_search"
        else
          "decidim/ad_users_space/forum_article_s"
        end
      end
    end
  end
end
