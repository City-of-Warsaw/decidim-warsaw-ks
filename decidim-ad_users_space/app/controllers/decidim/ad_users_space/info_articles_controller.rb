# frozen_string_literal: true

module Decidim::AdUsersSpace
  class InfoArticlesController < Decidim::ApplicationController
    layout "layouts/decidim/hero_section_banner"

    include Decidim::AdminExtended::HeroSectionHelper
    include Decidim::Paginable
    include Decidim::PaginateHelper
    include Decidim::SanitizeHelper

    helper Decidim::SanitizeHelper
    # helper Decidim::FollowableHelper
    # helper Decidim::Comments::CommentsHelper
    # helper Decidim::AttachmentsHelper

    helper_method :info_article, :info_articles, :article_categories, :orphan_articles, :hero_section_public,
                  :banner_partial_name, :pages_or_info_articles?

    def index; end

    def show
      raise ActionController::RoutingError, "Not Found" unless info_article
    end

    private

    def info_article
      @info_article ||= info_articles.find_by(id: params[:id])
    end

    def info_articles
      @info_articles ||= Decidim::AdUsersSpace::InfoArticle
                         .where(decidim_organization_id: current_organization.id)
    end

    def orphan_articles
      @orphan_articles ||= info_articles
                           .where(article_category_id: nil)
                           .sorted_by_weight
    end

    def article_categories
      @article_categories ||= Decidim::AdUsersSpace::ArticleCategory
                              .where(decidim_organization_id: current_organization.id)
                              .joins(:articles)
                              .distinct
                              .sorted_by_weight
    end
  end
end
