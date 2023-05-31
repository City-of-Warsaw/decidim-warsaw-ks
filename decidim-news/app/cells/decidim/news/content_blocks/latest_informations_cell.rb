# frozen_string_literal: true

module Decidim
  module News
    module ContentBlocks
      class LatestInformationsCell < Decidim::ViewModel
        include Decidim::CardHelper

        def show
          return if latest_informations.blank?

          render :show
        end

        def latest_informations
          @latest_informations ||= Decidim::News::Information
                               .where(organization: current_organization)
                               .order(created_at: :desc)
                               .limit(limit)
        end

        def all_news_path
          Decidim::News::Engine.routes.url_helpers.news_index_path
        end

        private

        def limit
          3
        end
      end
    end
  end
end
