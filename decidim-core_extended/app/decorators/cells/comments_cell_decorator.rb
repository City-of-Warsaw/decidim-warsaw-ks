# frozen_string_literal: true

Decidim::Comments::CommentsCell.class_eval do
  # overwritten method
  # use our view
  # in view swap user_signed_in? with model.can_participate?(current_user)
  def add_comment
    return if single_comment?
    return if comments_blocked?
    return if user_comments_blocked?

    render :add_comment_new
  end

  # overwritten method
  # use our view to hide elements if component: remarks / expert questions
  # - hide chat-1-line
  # - hide comments counter
  # - hide sorting
  # - show/hide comment form
  def show
    render :show_new
  end

  private

  def component_is_remarks_or_exp_questions?
    %w(remarks expert_questions consultation_map).include?(current_component&.manifest_name)
  end
end
