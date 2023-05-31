# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    #
    # A dummy presenter to abstract out the unregistered author.
    #
    class ExpertPresenter < SimpleDelegator
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper
      include Decidim::TranslatableAttributes

      #
      # nickname presented in a twitter-like style
      #
      def nickname
        "@#{__getobj__.position_and_name}"
      end

      def badge
        ""
      end

      delegate :url, to: :avatar, prefix: true

      def direct_messages_enabled?(context)
        false
      end

      def can_follow?
        false
      end

      def has_tooltip?
        false
      end
    end
  end
end
