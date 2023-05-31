# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    module Admin
      # This command is executed when user creates Article Category
      class CreateArticleCategory < Rectify::Command
        def initialize(form, user)
          @form = form
          @current_user = user
        end

        # Creates the article_category if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          create_article_category!

          broadcast(:ok, article_category)
        end

        private

        attr_reader :article_category, :form, :current_user

        def create_article_category!
          @article_category = Decidim.traceability.create!(
            Decidim::AdUsersSpace::ArticleCategory,
            current_user,
            article_category_params,
            visibility: "admin-only"
          )
        end

        def article_category_params
          {
            name: form.name,
            description: form.description,
            organization: current_user.organization
          }
        end
      end
    end
  end
end
