# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    class ForumArticleForm < Form
      attribute :title, String
      attribute :body, String

      validates :title, presence: true
      validates :body, presence: true

      mimic :forum_article

      alias organization current_organization

    end
  end
end
