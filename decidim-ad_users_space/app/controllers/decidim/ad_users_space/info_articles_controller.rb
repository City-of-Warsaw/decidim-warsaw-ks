# frozen_string_literal: true

module Decidim::AdUsersSpace
  class InfoArticlesController < Decidim::AdUsersSpace::ApplicationController
    layout "layouts/decidim/info_article"
    helper_method :articles_hero_section

    include Decidim::Paginable
    include Decidim::PaginateHelper
    include Decidim::SanitizeHelper
    # helper Decidim::FollowableHelper
    # helper Decidim::Comments::CommentsHelper
    # helper Decidim::AttachmentsHelper
    helper Decidim::SanitizeHelper

    helper_method :info_article, :info_articles, :help_section

    def index
      # @info_articles = info_articles.page(params[:page]).per(15)
      @topics = Decidim::AdUsersSpace::ArticleCategory.where(decidim_organization_id: current_organization.id)
      @orphan_articles = info_articles.where(article_category_id: nil)
    end

    def show
      info_article
      if info_article.article_category
        @info_articles = info_articles.where(article_category_id: info_article.article_category_id)
      end
    end

    private

    def info_article
      @info_article ||= info_articles.find_by(id: params[:id])
    end

    def info_articles
      InfoArticle.where(decidim_organization_id: current_organization.id)
    end

    def help_section
      @help_section ||= Decidim::ContextualHelpSection.find_content(current_organization, 'ad_help_pages')
    end

    def articles_hero_section
      @articles_hero_section ||= Decidim::AdminExtended::HeroSection.find_by(system_name: 'info_articles')
    end
  end
end
