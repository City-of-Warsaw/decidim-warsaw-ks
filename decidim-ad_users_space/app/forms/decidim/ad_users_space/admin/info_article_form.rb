# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    module Admin
      class InfoArticleForm < Form
        include Decidim::Repository::Admin::GalleryInputAttributes
        include Decidim::Repository::Admin::GalleriesValidations

        attribute :title, String
        attribute :body, String
        attribute :article_category_id, Integer
        attribute :weight, Integer

        validates :title, :body, presence: true

        mimic :info_article

        alias organization current_organization

        def map_model(model)
          super
          self.gallery_id = model.gallery_id
        end

        def article_categories_select
          @article_categories_select ||= Decidim::AdUsersSpace::ArticleCategory.where(decidim_organization_id: current_organization.id)
                                                                               .sorted_by_weight
                                                                               .pluck(:name, :id)
        end
      end
    end
  end
end
