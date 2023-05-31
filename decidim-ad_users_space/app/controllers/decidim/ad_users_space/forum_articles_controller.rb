# frozen_string_literal: true

module Decidim::AdUsersSpace
  class ForumArticlesController < Decidim::AdUsersSpace::ApplicationController
    layout "layouts/decidim/forum_article"

    include Decidim::Paginable
    include Decidim::PaginateHelper
    include Decidim::SanitizeHelper
    include Decidim::FormFactory
    # include Decidim::FilterResource
    # helper Decidim::FollowableHelper
    helper Decidim::Comments::CommentsHelper
    # helper Decidim::AttachmentsHelper
    helper Decidim::SanitizeHelper

    helper_method :forum_article, :forum_articles

    def index
      @searched_phrase = params.dig(:search, :text)

      @search_form = Decidim::AdUsersSpace::ForumArticleSearch.new(current_organization, search_params)
      @forum_articles = @search_form.results.page(params[:page]).per(15)

      view = @searched_phrase ? 'search' : 'index'
      render view
    end

    def show
      forum_article
      @comments = forum_article.comments.latest_first.page(params[:page]).per(15)
    end

    def new
      @form = form(Decidim::AdUsersSpace::ForumArticleForm).instance
    end

    def create
      @form = form(Decidim::AdUsersSpace::ForumArticleForm).from_params(params)

      Decidim::AdUsersSpace::CreateForumArticle.call(@form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("forum_articles.create.success", scope: "decidim")
          redirect_to forum_articles_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("forum_articles.create.error", scope: "decidim")
          render :new
        end
      end
    end

    private

    def search_params
      params.delete(:search) || {}
    end

    def forum_article
      @forum_article ||= forum_articles.find_by(id: params[:id])
    end

    def forum_articles
      ForumArticle.where(decidim_organization_id: current_organization.id)
    end
  end
end
