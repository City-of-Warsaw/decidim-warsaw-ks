# frozen_string_literal: true

module Decidim
  module AdUsersSpace
    module Admin
      # This command is executed when user destroys Info Article
      class DestroyInfoArticle < Rectify::Command
        def initialize(info_article, user)
          @info_article = info_article
          @current_user = user
        end

        # Creates the info_article if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          destroy_info_article!

          broadcast(:ok, info_article)
        end

        private

        attr_reader :info_article, :current_user

        def destroy_info_article!
          Decidim.traceability.perform_action!(
            :delete,
            info_article,
            current_user
          ) do
            info_article.destroy!
          end
        end
      end
    end
  end
end
