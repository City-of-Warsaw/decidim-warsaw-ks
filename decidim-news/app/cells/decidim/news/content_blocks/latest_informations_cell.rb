# frozen_string_literal: true

module Decidim
  module News
    module ContentBlocks
      class LatestInformationsCell < Decidim::ViewModel
        include Decidim::CardHelper
        include Decidim::News::UrlHelper

        def show
          return if latest_informations.blank?

          render :show
        end

        def latest_informations
          @latest_informations ||= Decidim::News::Information.where(decidim_organization_id: current_organization.id)
                                                             .published
                                                             .sorted_by_weight
                                                             .limit(limit)
        end

        private

        def limit
          3
        end

        def all_path
          decidim_news.news_index_path
        end
      end
    end
  end
end
