# frozen_string_literal: true

module Decidim
  module CommentsExtended
    # A command with all the business logic to create a new comment
    class UpdateComment < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
        @comment = form.comment
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :banned_word if the form includes banned words
      # - :invalid if the form wasn't valid and we couldn't proceed.
      # - :wrong_token if the form's token is different than comment
      #
      # Returns nothing.
      def call
        return broadcast(:banned_word) if form.invalid? && form.errors['body'].any?
        return broadcast(:invalid) if form.invalid?
        return broadcast(:wrong_token) if needs_token? && form.comment_token != comment.token

        update_comment

        broadcast(:ok, comment)
      end

      private

      attr_reader :form, :comment

      def update_comment
        # parsed = Decidim::ContentProcessor.parse(current_organization: form.current_organization)
        params = if form.is_a?(Decidim::CommentsExtended::CommentUpdateForm)
                   second_step_params
                 elsif form.is_a?(Decidim::CommentsExtended::FullCommentUpdateForm)
                   full_params
                 else
                   # user update
                   {
                     body: { 'pl' => form.body },
                     edited: true,
                     files: form.files
                   }
                 end

        @comment.update(params)
      end

      def needs_token?
        form.is_a?(Decidim::CommentsExtended::FullCommentUpdateForm) || form.is_a?(Decidim::CommentsExtended::CommentUpdateForm)
      end

      def second_step_params
        {
          email: form.email,
          age: form.age,
          gender: form.gender,
          district_id: form.district_id
          # token: nil # clearing token -> we not clearing token, so that user can update comment as long as he has his token
        }
      end

      def full_params
        second_step_params.merge(
          body: { 'pl' => form.body },
          signature: form.signature,
          files: form.files,
          edited: true # if full params, then it was edited
        )
      end
    end
  end
end
