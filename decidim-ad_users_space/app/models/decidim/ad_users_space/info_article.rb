# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    class InfoArticle < ApplicationRecord
      # include Decidim::HasAttachments
      # include Decidim::HasAttachmentCollections
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :organization,
                 foreign_key: 'decidim_organization_id',
                 class_name: 'Decidim::Organization'
      belongs_to :article_category,
                 foreign_key: 'article_category_id',
                 class_name: 'Decidim::AdUsersSpace::ArticleCategory',
                 optional: true
      belongs_to :gallery,
                 class_name: "Decidim::Repository::Gallery",
                 optional: true

      self.table_name = 'decidim_ad_users_space_info_articles'

      def self.log_presenter_class_for(_log)
        Decidim::AdUsersSpace::AdminLog::InfoArticlePresenter
      end
    end
  end
end
