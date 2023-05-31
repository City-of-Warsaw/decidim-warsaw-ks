# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    module Admin
      class InfoArticleForm < Form
        attribute :title, String
        attribute :body, String
        attribute :article_category_id, Integer
        attribute :gallery_id, Integer

        validates :title, presence: true
        validates :body, presence: true

        mimic :info_article

        alias organization current_organization

        def categories_select
          Decidim::AdUsersSpace::ArticleCategory.organization_categories(organization).map { |ac| [ac.name, ac.id] }
        end

        def article_category
          Decidim::AdUsersSpace::ArticleCategory.find_by(id: article_category_id)
        end
      end
    end
  end
end
