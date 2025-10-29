# frozen_string_literal: true

module Decidim
  module ConsultationRequests
    # This cell renders the Medium (:m) post card
    # for an given instance of a Post
    class ConsultationRequestSCell < Decidim::CardSCell
      include Rails.application.routes.mounted_helpers

      def show
        render :show
      end
      
      def author
        render :author
      end

      private

      def resource_path
        decidim_consultation_requests.consultation_request_path(model)
      end

      def date_of_submission
        "<strong>Data złożenia:</strong><span>#{model.date_of_request.strftime("%-d.%m.%Y")}</span>".html_safe if model.date_of_request.present?
      end

      def applicant
        "<strong>#{t(".applicant")}:</strong><span>#{model.applicant}</span>".html_safe if model.applicant.present?
      end

      def len
        @options[:length] || 210
      end

      def description
        text = model.body

        decidim_sanitize(truncate(strip_tags(text), length: len))
      end
    end
  end
end
