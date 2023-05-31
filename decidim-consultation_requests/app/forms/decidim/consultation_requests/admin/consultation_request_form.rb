# frozen_string_literal: true

module Decidim
  module ConsultationRequests
    module Admin
      class ConsultationRequestForm < Form
        attribute :title, String
        attribute :applicant, String
        attribute :body, String
        attribute :date_of_request, Decidim::Attributes::LocalizedDate
        attribute :comments_allowed, Boolean
        attribute :gallery_id, Integer

        mimic :consultation_request

        validates :title, presence: true
        validates :applicant, presence: true
        validates :body, presence: true
        validate :gallery_exists

        def gallery_exists
          return if gallery_id.blank?

          errors.add(:gallery_id, :gallery_not_found) unless Decidim::Repository::Gallery.find_by(id: gallery_id)
        end

        alias organization current_organization

        def comments_allowed
          false
        end
      end
    end
  end
end
