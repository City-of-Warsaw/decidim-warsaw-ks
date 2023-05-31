# frozen_string_literal: true

module Decidim::AdminExtended
  # Hero Sections are used for changing four header sections in public view:
  # - Decidim::News::Information
  # - Decidim::ConsultationRequests::ConsultationRequest
  # - Decidim::AdUsersSpace::InfoArticles
  # - Decidim::StaticPage
  class HeroSection < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable

    has_one_attached :banner_img

    validate :acceptable_banner_img

    # Presenter class for AdminLogs
    def self.log_presenter_class_for(_log)
      Decidim::AdminExtended::AdminLog::HeroSectionPresenter
    end

    def acceptable_banner_img
      return unless banner_img.attached?

      unless banner_img.byte_size <= 50.megabyte
        errors.add(:banner_img, "Maksymalny rozmiar pliku to 50 mb")
      end

      acceptable_types = ["image/jpg", "image/jpeg", "image/png"]
      unless acceptable_types.include?(banner_img.content_type)
        errors.add(:banner_img, "Dozwolone rozszerzenia plików: jpg jpeg png")
      end
    end
  end
end
