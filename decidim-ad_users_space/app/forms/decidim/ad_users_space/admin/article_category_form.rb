# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    module Admin
      class ArticleCategoryForm < Form
        attribute :name, String
        attribute :description, String

        validates :name, presence: true

        mimic :article_category

        alias organization current_organization
      end
    end
  end
end
