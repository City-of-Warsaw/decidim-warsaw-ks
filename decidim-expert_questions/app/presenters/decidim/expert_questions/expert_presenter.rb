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

      #  Needed for author_cell
      def name
        full_name
      end

      #
      # nickname presented in a twitter-like style
      #
      def nickname
        "@#{__getobj__.full_name}"
      end

      def badge
        ""
      end

      def avatar
        attached_uploader(:avatar)
      end

      def avatar_url(variant = nil)
        return default_avatar_url
        return default_avatar_url unless avatar.attached?

        avatar.path(variant: variant)
      end

      def default_avatar_url
        avatar.default_url
      end

      def direct_messages_enabled?(context)
        false
      end

      def has_tooltip?
        false
      end
    end
  end
end
