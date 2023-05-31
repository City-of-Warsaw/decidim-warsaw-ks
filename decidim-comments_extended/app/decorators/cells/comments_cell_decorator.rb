# frozen_string_literal: true

Decidim::Comments::CommentsCell.class_eval do
  def show
    render :show_new
  end
  
  def add_comment
    return if single_comment?
    return if comments_blocked?
    return if user_comments_blocked? && !unregistered_user_can_add_comment?
    return if map_remark_and_not_ad_user?
    return if expert_user_question_and_not_ad_user?

    render :add_comment_new
  end

  def blocked_comments_warning
    return unless comments_blocked? # show also for unregistered user

    render :blocked_comments_warning
  end

  def alignment_enabled?
    return false unless user_signed_in?

    # model.comments_have_alignment?
    false
  end

  def for_reader
    @options[:for_reader]
  end

  private

  def available_orders
    %w(recent older most_discussed)
  end

  def comments_blocked?
    !model.accepts_new_comments?
  end

  def unregistered_user_can_add_comment?
    return if single_comment?
    return if comments_blocked?
    return if user_comments_blocked_in_space?

    true
  end 

  def user_comments_blocked_in_space?
    !model.allowed_to_comment?(current_user)
  end

  def map_remark_and_not_ad_user?
    commenting_map_remark? && !current_user&.has_ad_role?
  end

  def expert_user_question_and_not_ad_user?
    commenting_expert_user_question? && !current_user&.has_ad_role?
  end

  def commenting_map_remark?
    model.is_a?(Decidim::ConsultationMap::Remark) ||
      (model.respond_to?(:root_commentable) && model.root_commentable.is_a?(Decidim::ConsultationMap::Remark))
  end

  def commenting_expert_user_question?
    model.is_a?(Decidim::ExpertQuestions::UserQuestion) ||
      (model.respond_to?(:root_commentable) && model.root_commentable.is_a?(Decidim::ExpertQuestions::UserQuestion))
  end
end
