# frozen_string_literal: true

module Decidim
  module CommentsExtended
    # Controller that manages the comments update
    #
    class CommentsController < Decidim::Comments::ApplicationController
      include Decidim::FormFactory
      # include Decidim::ResourceHelper

      helper_method :root_depth, :commentable, :order, :reply?, :reload?, :update_error, :wrong_token_error,
                    :thank_you_message, :comments_max_length, :close_modal, :update_form_object

      # Action used when user clicks "edit" button
      def edit
        if comment.authored_by?(current_user) || (!current_user && comment.token == session[:comment_token])
          @form_object = if current_user
                           form(Decidim::Comments::CommentForm).from_model(comment)
                         else
                           form(Decidim::CommentsExtended::FullCommentUpdateForm).from_model(comment)
                         end

          respond_to do |format|
            format.js { render :full_edit }
          end
        else
          respond_to do |format|
            format.js { render :wrong_token }
          end
        end
      end

      # Action is used for updating second step of adding comment.
      # Only Unregistered users are shown this action
      def update
        enforce_permission_to :create, :comment, commentable: commentable
        @form_object = Decidim::CommentsExtended::CommentUpdateForm.from_params(
          params[:comment].merge({ comment: comment,
                              comment_token: session[:comment_token] })
        )

        Decidim::CommentsExtended::UpdateComment.call(@form_object) do
          on(:ok) do |comment|
            respond_to do |format|
              format.js { render :update }
            end
          end

          on(:wrong_token) do
            respond_to do |format|
              format.js { render :wrong_token }
            end
          end

          on(:banned_word) do
            respond_to do |format|
              format.js { render :edit }
            end
          end

          on(:invalid) do
            respond_to do |format|
              format.js { render :error }
            end
          end
        end
      end

      # Action used from the proper edit view
      def full_update
        @form_object = if current_user
                        form(Decidim::Comments::CommentForm).from_params(params[:comment].merge(comment: comment))
                      else
                        form(Decidim::CommentsExtended::FullCommentUpdateForm)
                          .from_params(
                            params[:full_comment_update].merge({comment: comment, comment_token: params[:comment_token]})
                          )
                      end

        Decidim::CommentsExtended::UpdateComment.call(@form_object) do
          on(:ok) do |comment|
            respond_to do |format|
              format.js { render :update }
            end
          end

          on(:wrong_token) do
            respond_to do |format|
              format.js { render :wrong_token }
            end
          end

          on(:banned_word) do
            respond_to do |format|
              format.js { render current_user ? :edit : :full_edit }
            end
          end

          on(:invalid) do
            respond_to do |format|
              format.js { render :error_full }
            end
          end
        end
      end

      def commentable
        @commentable ||= comment.commentable
      end

      def comment
        @comment ||= Decidim::Comments::Comment.find params[:id]
      end

      def update_error
        @update_error ||= t("update.error", scope: "decidim.comments.comments")
      end

      def wrong_token_error
        @wrong_token_error ||= t("update.wrong_token_error", scope: "decidim.comments.comments")
      end

      def thank_you_message
        @thank_you_message ||= t("update.thank_you_message", scope: "decidim.comments.comments")
      end

      def close_modal
        @thank_you_message ||= t("update.close_modal", scope: "decidim.comments.comments")
      end

      def comments_max_length
        return 1000 unless current_component.respond_to?(:settings)
        return 1000 unless current_component.settings.respond_to?(:comments_max_length)
        return current_component.settings.comments_max_length if current_component.respond_to?(:settings) && current_component.settings.comments_max_length.positive?

        1000
      end

      def current_component
        comment.root_commentable.try(:component) || comment.root_commentable
      end

      def reply?(comment)
        comment.root_commentable != comment.commentable
      end

      def order
        params.fetch(:order, "older")
      end

      def reload?
        params.fetch(:reload, 0).to_i == 1
      end

      def root_depth
        params.fetch(:root_depth, 0).to_i
      end

      # Method setting form object for edit.js
      def update_form_object(comment)
        Decidim::CommentsExtended::CommentUpdateForm.from_model(comment)
      end
    end
  end
end
