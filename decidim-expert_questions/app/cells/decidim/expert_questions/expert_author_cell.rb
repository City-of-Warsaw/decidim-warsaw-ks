# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    class ExpertAuthorCell < Decidim::AuthorCell
      include ActionView::Helpers::DateHelper

      def show
        render :show
      end

      def date
        options[:date]
      end

      private

      def creation_date
        date_at = model.try(:published_at) || model.try(:created_at)

        l date_at, format: :decidim_short_no_time
      end

      def creation_date?
        true
      end

      def profile_path?
        false
      end
    end
  end
end
