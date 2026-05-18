# frozen_string_literal: true

Decidim::Comments::CommentCell.class_eval do
  include Decidim::CoreExtended::AuthorForCells

  # overwritten method-view
  # use our show - allow unregistered author to edit
  def show
    render :show_new
  end

  def frontend_administrable?
    user_entity? &&
      model.can_be_administered_by?(current_user) &&
      (model.respond_to?(:official?) && !model.official?)
  end

  # overwritten method
  # kill caching
  # TODO: PO UKOŃCZONYCH TESTACH KLIENTA V29 rollback - cofnąć to nadpisanie
  def perform_caching?
    false
  end

  # Gives colour to a comment whose author is an internal user - AD user
  def admin_response_class
    classes = []
    classes << "admin-response" if author_is_admin?

    classes.join(" ")
  end

  def can_edit_comment?(model, token)
    (current_user.present? && model.authored_by?(current_user)) || (token.present? && token == model.token)
  end

  def can_delete_comment?(model)
    current_user.present? && model.authored_by?(current_user)
  end

  private

  # use token from options if given or from cookies
  def token
    options[:edit_token] || cookies_comment_edit_token(model)
  end

  # overwritten method
  # used a new way to present users with included Author For Cells
  def author_presenter
    super
  end

  # is author an internal user - AD user
  # returns boolean
  def author_is_admin?
    model.author.is_a?(Decidim::User) && model.author.has_ad_role?
  end

  # overwritten method
  # remove checking process space and decidim user role
  # remove checking user signed in
  # allow unregistered user to reply
  # add additional scenarios
  def can_reply?
    return false if model.depth >= Decidim::Comments::Comment::MAX_DEPTH

    is_not_admin = !current_user&.has_ad_role?

    # block replies to remark's comment unless current user is admin
    return false if model.root_commentable.is_a?(Decidim::Remarks::Remark) && is_not_admin

    # block replies to admin comment unless current user is admin
    return false if author_is_admin? && is_not_admin

    # block non-admins (and unregistered) from replying to reply
    return false if model.depth >= 1 && is_not_admin

    accepts_new_comments? && root_commentable.user_allowed_to_comment?(current_user)
  end

  # overwritten method
  # make it nil
  # TODO: PO UKOŃCZONYCH TESTACH KLIENTA V29 rollback - cofnąć to nadpisanie
  def cache_hash
    nil
  end

  def user_entity?
    (model.respond_to?(:creator_author) && model.creator_author.respond_to?(:nickname)) ||
      (model.respond_to?(:author) && model.author.respond_to?(:nickname))
  end
end
