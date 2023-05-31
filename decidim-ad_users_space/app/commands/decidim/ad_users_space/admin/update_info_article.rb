# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    module Admin
      # This command is executed when user updates Info Article
      class UpdateInfoArticle < Rectify::Command

        def initialize(info_article, form, user)
          @form = form
          @info_article = info_article
          @current_user = user
        end

        # Creates the info_article if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_info_article!

          broadcast(:ok, info_article)
        end

        private

        attr_reader :info_article, :form, :current_user

        def update_info_article!
          Decidim.traceability.update!(
            info_article,
            current_user,
            info_article_params,
            visibility: "admin-only"
          )
        end

        def info_article_params
          {
            title: form.title,
            body: form.body,
            article_category: form.article_category,
            gallery_id: form.gallery_id
          }
        end
      end
    end
  end
end
