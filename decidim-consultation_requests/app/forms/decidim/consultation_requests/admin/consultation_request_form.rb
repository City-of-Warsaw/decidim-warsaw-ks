# frozen_string_literal: true

module Decidim
  module ConsultationRequests
    module Admin
      class ConsultationRequestForm < Form
        include Decidim::Repository::Admin::GalleryInputAttributes
        include Decidim::Repository::Admin::GalleriesValidations

        attribute :title, String
        attribute :applicant, String
        attribute :body, String
        attribute :date_of_request, Decidim::Attributes::LocalizedDate

        mimic :consultation_request

        validates :title, :applicant, :body, presence: true

        alias organization current_organization

        def map_model(model)
          super
          self.gallery_id = model.gallery_id
        end
      end
    end
  end
end
