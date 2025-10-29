# frozen_string_literal: true

module Decidim
  module CoreExtended
    module CommentTokenCookie
      extend ActiveSupport::Concern

      included do
        helper_method :cookies_comment_edit_token
      end

      private

      # Private method
      # verify token - only for unregistered authors
      def cookies_comment_edit_token(comment)
        cookies["comment_edit_token_#{comment.id}"]
      end
    end
  end
end
