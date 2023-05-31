# frozen_string_literal: true

require_dependency "decidim/news/application_controller"

module Decidim::News
  class InformationsController < ApplicationController
    layout "layouts/decidim/information"
    helper_method :help_section, :news_hero_section

    include Decidim::Paginable
    # include Decidim::PaginateHelper
    # include Decidim::SanitizeHelper
    helper Decidim::FollowableHelper
    helper Decidim::Comments::CommentsHelper
    helper Decidim::AttachmentsHelper
    helper Decidim::SanitizeHelper

    helper_method :information, :informations

    def index
      @informations = informations.page(params[:page]).per(15)
    end

    def show
      information
    end

    private

    def information
      @information ||= informations.find_by(id: params[:id])
    end

    def informations
      Information.where(decidim_organization_id: current_organization.id)
    end

    def help_section
      @help_section ||= Decidim::ContextualHelpSection.find_content(current_organization, 'help_pages')
    end

    def news_hero_section
      @news_hero_section ||= Decidim::AdminExtended::HeroSection.find_by(system_name: 'news')
    end
  end
end
