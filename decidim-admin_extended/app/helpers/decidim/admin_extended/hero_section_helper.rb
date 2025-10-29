# frozen_string_literal: true

module Decidim
  module AdminExtended
    # This helper enables to dynamically render particular header for particular space
    module HeroSectionHelper
      def hero_section_public
        case controller_name
        when 'informations'
          Decidim::AdminExtended::HeroSection.find_by(system_name: 'news')
        when 'consultation_requests'
          Decidim::AdminExtended::HeroSection.find_by(system_name: 'consultation_requests')
        when 'info_articles'
          Decidim::AdminExtended::HeroSection.find_by(system_name: 'info_articles')
        when 'faqs'
          Decidim::AdminExtended::HeroSection.find_by(system_name: 'faqs')

        # decidim_static_page table has column that allow/disallow to be shown on help page.
        # If static page is hidden - then do not render banner for that page
        when 'pages'
          if @show_page_header
            Decidim::AdminExtended::HeroSection.find_by(system_name: 'pages')
          else
            nil
          end
        end
      end

      def info_or_request_title
        case hero_section_public.system_name
        when 'news'
          information.title
        when 'consultation_requests'
          consultation_request.title
        end
      end

      def banner_partial_name(hero_section_public)
        if ['news'].include?(hero_section_public.system_name) && action_name == 'show'
          "news_info_and_request_banner_header"
        elsif ['consultation_requests'].include?(hero_section_public.system_name) && action_name == 'show'
          "consultation_requests_info_and_request_banner_header"
        else
          "hero_section_banner_header"
        end
      end

      def pages_or_info_articles?
        if hero_section_public.system_name == 'pages' || hero_section_public.system_name == 'info_articles'
          true
        end
      end
    end
  end
end
