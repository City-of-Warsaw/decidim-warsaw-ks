# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    class ArticleCategory < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :organization,
                 foreign_key: "decidim_organization_id",
                 class_name: "Decidim::Organization"

      has_many :articles,
               foreign_key: :article_category_id,
               class_name: "Decidim::AdUsersSpace::InfoArticle",
               dependent: :destroy

      scope :sorted_by_weight, -> { order(:weight) }

      self.table_name = "decidim_ad_users_space_article_categories"

      def self.log_presenter_class_for(_log)
        Decidim::AdUsersSpace::AdminLog::ArticleCategoryPresenter
      end
    end
  end
end
