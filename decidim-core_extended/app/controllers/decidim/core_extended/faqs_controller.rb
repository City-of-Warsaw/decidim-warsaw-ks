# frozen_string_literal: true

require_dependency "decidim/admin_extended/application_controller"

module Decidim
  module CoreExtended
    class FaqsController < ApplicationController
      layout "layouts/decidim/hero_section_banner"

      include Decidim::AdminExtended::HeroSectionHelper

      helper Decidim::AttachmentsHelper
      helper Decidim::SanitizeHelper

      helper_method :faq_groups, :hero_section_public, :info_or_request_title, :banner_partial_name,
                    :pages_or_info_articles?

      def index; end

      private

      def faq_groups
        @faq_groups ||= Decidim::AdminExtended::FaqGroup.sorted_by_weight.published.includes(:faqs)
      end
    end
  end
end
