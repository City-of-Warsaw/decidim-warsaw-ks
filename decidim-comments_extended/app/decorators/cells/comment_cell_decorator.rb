# frozen_string_literal: true

Decidim::Comments::CommentCell.class_eval do

  def show
    render :show_new
  end

  def decidim_comments_extended
    Decidim::CommentsExtended::Engine.routes.url_helpers
  end

  def order
    "older"
  end

  def for_reader
    @options[:for_reader]
  end

  def reply_id
    "comment#{model.id}-reply#{for_reader}"
  end

  private

  def can_be_reported?
    return false if model.root_commentable.is_a?(Decidim::AdUsersSpace::ForumArticle)

    true
  end

  def author_presenter
    if model.author.respond_to?(:official?) && model.author.official?
      Decidim::Debates::OfficialAuthorPresenter.new
    elsif model.respond_to?(:unregistered_author?) && model.unregistered_author?
      model.signature.present? ? Decidim::CommentsExtended::UnregisteredAuthorPresenter.new(name_param: 'signed', signature: model.signature) : Decidim::CommentsExtended::UnregisteredAuthorPresenter.new
    elsif model.author.respond_to?(:has_ad_role?) && model.author.has_ad_role?
      Decidim::CommentsExtended::UnregisteredAuthorPresenter.new(name_param: 'ad_user')
    elsif model.user_group
      model.user_group.presenter
    else
      model.author.presenter
    end
  end

  def can_reply?
    if author_is_admin?
      false
    elsif root_commentable.is_a?(Decidim::ConsultationMap::Remark)
      # only one depth of comments to Consultation Map
      false
    elsif root_commentable.is_a?(Decidim::ExpertQuestions::UserQuestion)
      # only one depth of comments to Expert Question
      false
    elsif root_commentable.is_a?(Decidim::Proposals::Proposal)
      !model.component.users_action_disallowed? || (model.component.users_action_disallowed? && current_user && current_user.has_ad_role?)
    elsif root_commentable.is_a?(Decidim::Remarks::Remark)
      # second depth of commenting only for ad users
      !!current_user&.has_ad_role?
    else
      accepts_new_comments?(!!current_user&.has_ad_role?) && root_commentable.allowed_to_comment?(current_user)
    end
  end

  def authored_by_unregistered?(session_comment_token)
    return false unless session_comment_token.present?
    return false unless model.respond_to?(:token)
    return false unless model.token.present?
    return false if current_user

    session_comment_token == model.token && model.authored_by?(current_organization.unregistered_author)
  end

  def comment_classes
    classes = ["comment"]
    classes << "admin-response" if author_is_admin?

    classes.join(" ")
  end

  def commentable_path(params = {})
    if root_commentable.is_a?(Decidim::Budgets::Project)
      resource_locator([root_commentable.budget, root_commentable]).path(params)
    elsif unscoped_element?
      unscoped_locator(params)
    else
      resource_locator(root_commentable).path(params)
    end
  end

  # Method that skips one modal on map view for doubled elements
  def show_modal?
    root_commentable.class.name == "Decidim::ConsultationMap::Remark" && for_reader.present?
  end

  # method checkes if a root commentable is one of custom elements from outside space
  def unscoped_element?
    # TODO: dodac pozostale
    root_commentable.is_a?(Decidim::News::Information) ||
      root_commentable.is_a?(Decidim::ConsultationRequests::ConsultationRequest)
  end

  # method sets custom routes for elements from outside space
  # possible to move out to a new locator presenter
  def unscoped_locator(params)
    # TODO: dodac pozostale
    case root_commentable.class.name
    when "Decidim::News::Information"
      decidim_news.information_path(root_commentable)
    when "Decidim::ConsultationRequests::ConsultationRequest"
      decidim_consultation_requests.consultation_request_path(root_commentable)
    end
  end

  def author_is_admin?
    model.author.is_a?(Decidim::User) && model.author.has_ad_role?
  end

  def decidim_news
    Decidim::News::Engine.routes.url_helpers
  end

  def decidim_consultation_requests
    Decidim::ConsultationRequests::Engine.routes.url_helpers
  end
end
