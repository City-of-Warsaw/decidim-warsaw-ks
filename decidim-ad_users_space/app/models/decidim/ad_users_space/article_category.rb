# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    class ArticleCategory < ApplicationRecord
      # include Decidim::HasAttachments
      # include Decidim::HasAttachmentCollections
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :organization,
                 foreign_key: 'decidim_organization_id',
                 class_name: 'Decidim::Organization'

      has_many :articles,
               foreign_key: :article_category_id,
               class_name: "Decidim::AdUsersSpace::InfoArticle",
               dependent: :destroy

      scope :organization_categories, -> (organization_id) { where('decidim_ad_users_space_article_categories.decidim_organization_id': organization_id) }

      self.table_name = 'decidim_ad_users_space_article_categories'

      def self.log_presenter_class_for(_log)
        Decidim::AdUsersSpace::AdminLog::ArticleCategoryPresenter
      end
    end
  end
end
