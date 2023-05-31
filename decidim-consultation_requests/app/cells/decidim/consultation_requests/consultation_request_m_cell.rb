# frozen_string_literal: true

module Decidim
  module ConsultationRequests
    # This cell renders the Medium (:m) post card
    # for an given instance of a Post
    class ConsultationRequestMCell < Decidim::CardMCell
      include Rails.application.routes.mounted_helpers

      def resource_path
        decidim_consultation_requests.consultation_request_path(model)
      end

      def column_size_classes
        options[:column_size_classes]
      end

      def author
        render :author
      end

      private

      def description
        text = model.body

        decidim_sanitize(html_truncate(text, length: 250))
      end

      def date_of_request
        l(model.date_of_request, format: :decidim_short)
      end

      def avatar_url
        current_organization.favicon.url.presence || ActionController::Base.helpers.asset_path("decidim/default-avatar.svg")
      end

      # TODO: change when attachmants are added
      def has_image?
        false
      end

      # used for displaying coauthorship in author cell, and for voting and other actions
      def has_actions?
        false
      end
    end
  end
end
