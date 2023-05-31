# frozen_string_literal: true

Decidim::Comments::CommentsController.class_eval do
  skip_before_action :authenticate_user!

  helper_method :update_form_object, :comments_max_length

  def index
    enforce_permission_to :read, :comment, commentable: commentable

    @comments = Decidim::Comments::SortedComments.for(
      commentable,
      order_by: order,
      after: params.fetch(:after, 0).to_i
    ).with_attached_files
    @comments_count = commentable.comments.count

    respond_to do |format|
      format.js do
        if reload?
          render :reload
        else
          # if commentable_is_in_batch?
          #   head :ok
          # else
          #   render :index
          # end
          head :ok
        end
      end

      # This makes sure bots are not causing unnecessary log entries.
      format.html { redirect_to commentable_path }
    end
  end

  def create
    enforce_permission_to :create, :comment, commentable: commentable

    @form_object = Decidim::Comments::CommentForm.from_params(params.merge(commentable: commentable))
                                                 .with_context(
                                                   current_organization: current_organization, # needed for command
                                                   current_component: commentable.try(:component) || commentable.try(:participatory_space) || commentable
                                                 )

    Decidim::Comments::CreateComment.call(@form_object, current_user, session[:comment_token]) do
      on(:ok) do |comment|
        handle_success(comment)
        respond_to do |format|
          if comment.unregistered_author?
            session[:comment_token] = comment.token
            format.js { render('decidim/comments_extended/comments/edit') }
          else
            format.js { render :create }
          end
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

  def update_form_object(comment)
    Decidim::CommentsExtended::CommentUpdateForm.from_model(comment)
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
end
