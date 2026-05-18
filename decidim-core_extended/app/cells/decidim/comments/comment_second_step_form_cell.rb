# frozen_string_literal: true

module Decidim
  module Comments
    class CommentSecondStepFormCell < Decidim::ViewModel
      alias comment model

      private

      def form_id
        "second_step_update_#{comment.id}"
      end

      # use token from options if given or from cookies
      def token
        options[:edit_token] || cookies_comment_edit_token(model)
      end

      # overwritten method
      # kill caching
      # TODO: PO UKOŃCZONYCH TESTACH KLIENTA V29 rollback - cofnąć to nadpisanie
      def perform_caching?
        false
      end

      # overwritten method
      # make it nil
      # TODO: PO UKOŃCZONYCH TESTACH KLIENTA V29 rollback - cofnąć to nadpisanie
      def cache_hash
        nil
      end

      # overwritten method
      # add token & use form_object option if given
      def form_object
        options[:form_object] || Decidim::Comments::CommentForm.new(
          body: comment.translated_body,
          token: comment.token
        )
      end
    end
  end
end
