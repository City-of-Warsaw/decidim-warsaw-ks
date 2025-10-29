# frozen_string_literal: true

module Decidim
  module AdminExtended
    # Hero Sections are used for changing four header sections in public view:
    # - Decidim::News::Information
    # - Decidim::ConsultationRequests::ConsultationRequest
    # - Decidim::AdUsersSpace::InfoArticles
    # - Decidim::StaticPage
    # - Decidim::AdminExtended::Faq
    class HeroSection < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable

      # Presenter class for AdminLogs
      def self.log_presenter_class_for(_log)
        Decidim::AdminExtended::AdminLog::HeroSectionPresenter
      end

      def maximum_upload_size
        50.megabytes
      end

      # needed for validations
      def organization
        Decidim::Organization.first
      end
    end
  end
end
