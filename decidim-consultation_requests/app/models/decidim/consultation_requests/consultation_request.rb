# frozen_string_literal: true

module Decidim
  module ConsultationRequests
    # A Consultation Request is used to add content to public view.
    class ConsultationRequest < ApplicationRecord
      include Decidim::Searchable
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :organization,
                 foreign_key: "decidim_organization_id",
                 class_name: "Decidim::Organization"

      belongs_to :gallery, class_name: "Decidim::Repository::Gallery", optional: true

      scope :latest_first, -> { order(date_of_request: :desc) }

      self.table_name = "decidim_consultation_requests"

      def self.log_presenter_class_for(_log)
        Decidim::ConsultationRequests::AdminLog::ConsultationRequestPresenter
      end

      searchable_fields({
                          participatory_space: :itself,
                          D: :body,
                          A: :title,
                          datetime: :created_at
                        },
                        index_on_create: true,
                        index_on_update: true)
    end
  end
end
