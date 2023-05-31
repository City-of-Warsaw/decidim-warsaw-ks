# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    module Admin
      # This command is executed when user creates Info Article
      class CreateInfoArticle < Rectify::Command
        def initialize(form, user)
          @form = form
          @current_user = user
        end

        # Creates the info_article if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          create_info_article!

          broadcast(:ok, info_article)
        end

        private

        attr_reader :info_article, :form, :current_user

        def create_info_article!
          @info_article = Decidim.traceability.create!(
            Decidim::AdUsersSpace::InfoArticle,
            current_user,
            info_article_params,
            visibility: "admin-only"
          )
        end

        def info_article_params
          {
            title: form.title,
            body: form.body,
            organization: current_user.organization,
            article_category: form.article_category,
            gallery_id: form.gallery_id
          }
        end
      end
    end
  end
end
