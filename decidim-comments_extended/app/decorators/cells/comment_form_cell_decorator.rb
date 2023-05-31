# frozen_string_literal: true

Decidim::Comments::CommentFormCell.class_eval do
  include ActionView::Helpers::FormOptionsHelper
  # include Decidim::CommentsExtended::Engine.routes.url_helpers

  def show
    if user_signed_in?
      show_for_registered
    elsif unregistered_user_can_add_comment?
      render :show_for_unregistered
    end
  end

  def edit_comment
    render :edit_comment
  end

  def show_for_unregistered
    render :show_for_unregistered
  end

  def show_for_registered
    render :show_new
  end

  def form_id
    "new_comment_for_#{commentable_type.demodulize}_#{model.id}#{for_reader}"
  end

  def add_comment_id
    "add-comment-#{commentable_type.demodulize}-#{model.id}#{for_reader}"
  end

  def for_reader
    @options[:for_reader]
  end

  def processed_form
    @options[:error_form] || form_object
  end

  private

  def comments_max_length
    return 4000 unless model.respond_to?(:component)
    return component_comments_max_length if component_comments_max_length
    return organization_comments_max_length if organization_comments_max_length

    4000
  end

  def unregistered_user_can_add_comment?
    return if user_comments_blocked_in_space?

    model.accepts_new_comments?
  end

  def update_form_object(comment)
    Decidim::CommentsExtended::CommentUpdateForm.().from_model(
      comment: comment
    )
  end

  def user_comments_blocked_in_space?
    !model.accepts_new_comments?
  end
end
