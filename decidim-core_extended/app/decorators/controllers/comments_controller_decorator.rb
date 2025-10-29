# frozen_string_literal: true

Decidim::Comments::CommentsController.class_eval do
  include Decidim::CoreExtended::CommentTokenCookie

  skip_before_action :authenticate_user!, only: [:create]

  # overwritten method
  # turn off enforce permission
  # allow to unregistered author update comment
  def update
    set_comment

    set_commentable
    # enforce_permission_to(:update, :comment, comment:)
    authorize_edit_token!(comment)

    @form = Decidim::Comments::CommentForm.from_params(
      params.merge(commentable: comment.commentable)
    ).with_context(
      current_user: user_entity_or_unregistered_author,
      current_organization:,
      current_component:
    )

    Decidim::Comments::UpdateComment.call(comment, @form) do
      on(:ok) do
        respond_to do |format|
          format.js { render :update }
        end
      end

      on(:invalid) do
        respond_to do |format|
          format.js { render :update_error }
        end
      end
    end
  end

  # overwritten method
  # turn off enforce permission
  # allow to unregistered author create comment
  def create
    # enforce_permission_to(:create, :comment, commentable:)

    @form = Decidim::Comments::CommentForm.from_params(
      params.merge(commentable:)
    ).with_context(
      current_organization:,
      current_component:,
      current_user: user_entity_or_unregistered_author
    )
    Decidim::Comments::CreateComment.call(@form) do
      on(:ok) do |comment|
        handle_success(comment)
        respond_to do |format|
          format.js { render :create }
        end
      end

      on(:invalid) do
        @error = t("create.error", scope: "decidim.comments.comments")
        respond_to do |format|
          format.js { render :error }
        end
      end
    end
  end

  private

  # Private method
  # returns special object that serves as Author for comments created by unregistered users
  def unregistered_author
    @unregistered_author ||= Decidim::CoreExtended::UnregisteredAuthor.first
  end

  # Private method
  #
  # returns boolean
  def user_entity_or_unregistered_author
    current_user || unregistered_author
  end

  def authorize_edit_token!(comment)
    token = params.dig(:comment, :token)
    # Allow if logged-in user is the author
    return if current_user.present? && current_user == comment.author

    # Otherwise, verify token (for unregistered authors)
    raise ActionController::RoutingError, "Not authorized" unless token.present? && ActiveSupport::SecurityUtils.secure_compare(comment.token, token)
  end
end
