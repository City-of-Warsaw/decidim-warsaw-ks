# frozen_string_literal: true

Decidim::Comments::CreateComment.class_eval do

  # OVERWRITTEN DEVIDIM METHOD
  # Public: Initializes the command.
  #
  # form - A form object with the params.
  # comment_token - passed from session, so one token can be used for many comments
  def initialize(form, author, comment_token)
    @form = form
    @author = author || unregistered_author
    @comment_token = comment_token
  end

  private

  # OVERWRITTEN DECIDIM METHOD
  # Private: Creates comment and handles notifications
  #
  # Params were taken out from the method
  def create_comment
    parsed = Decidim::ContentProcessor.parse(form.body, current_organization: form.current_organization)

    @comment = Decidim.traceability.create!(
      Decidim::Comments::Comment,
      @author,
      comment_params(parsed),
      visibility: "public-only"
    )

    touch_root_commentable_or_comments

    Decidim::Comments::CommentCreation.publish(@comment, parsed.metadata)

    notify_about_commented_proposal
    notify_about_commented_remark
  end

  # Depending on which space the comment has been added to:
  def touch_root_commentable_or_comments
    # after add new child-comment, in space: Decidim::News::Information - update parent
    if @comment.root_commentable.is_a? Decidim::News::Information
      @comment.commentable.touch
    elsif @comment.root_commentable.is_a? Decidim::ConsultationMap::Remark
      # after add new comment to remark, in space: Decidim::News::Information
      # root object should change sorting order
      @comment.root_commentable.touch
      # after add new comment to remark, in space: Decidim::Remarks::Remark
      # root object should change sorting order
    elsif @comment.root_commentable.is_a? Decidim::Remarks::Remark
      @comment.root_commentable.touch
      # after add new child-comment, in space: Decidim::Proposals::Proposal - update parent
    elsif @comment.root_commentable.is_a? Decidim::Proposals::Proposal
      @comment.commentable.touch
      # after add new child-comment, in space: Decidim::Meetings::Meeting - update parent
    elsif @comment.root_commentable.is_a? Decidim::Meetings::Meeting
      @comment.commentable.touch
    else
      # after add new child-child-comment, to Decidim::Comments::Comment, in one of the spaces listed above
      # update parent
      if @comment.commentable&.is_a?(Decidim::Comments::Comment) &&
         @comment.commentable&.commentable && @comment.commentable.commentable.is_a?(Decidim::Comments::Comment)
        @comment.commentable.commentable.touch
      else
        @comment.commentable.touch
      end
    end
  end

  def notify_about_commented_proposal
    return unless @comment.root_commentable.is_a?(Decidim::Proposals::Proposal)

    proposal = @comment.root_commentable

    Decidim::NotificationGenerator.new(
      "decidim.events.comments.comment_created",
      Decidim::Comments::CommentCreatedEvent,
      proposal,
      proposal.followers, # followers
      Decidim::User.none, # affected_users
      {
        comment_id: @comment.id
      }
    ).generate

    Decidim::CoreExtended::TemplatedMailerJob.perform_now('new_comment_to_proposal', { resource: @comment })
  end

  def notify_about_commented_remark
    return unless @comment.root_commentable.is_a?(Decidim::Remarks::Remark)

    remark = @comment.root_commentable

    Decidim::NotificationGenerator.new(
      "decidim.events.comments.comment_created",
      Decidim::Comments::CommentCreatedEvent,
      remark,
      remark.component.participatory_space.find_possible_followers, # followers
      Decidim::User.none, # affected_users
      {
        comment_id: @comment.id
      }
    ).generate

    Decidim::CoreExtended::TemplatedMailerJob.perform_now('new_comment_to_remark', { resource: @comment })
  end

  # Private method mapping form params into comment attributes
  #
  # Returns Hash
  def comment_params(parsed)
    {
      author: @author,
      commentable: form.commentable,
      root_commentable: root_commentable(form.commentable),
      body: { I18n.locale => parsed.rewrite },
      alignment: form.alignment,
      decidim_user_group_id: form.user_group_id,
      # custom
      signature: form.signature,
      token: assign_token,
      files: form.files
    }
  end

  # Private method returning special object that serves as Author for comments created by unregistered users
  def unregistered_author
    Decidim::CommentsExtended::UnregisteredAuthor.find_by(organization_id: form.current_organization.id)
  end

  def assign_token
    if @author.is_a?(Decidim::CommentsExtended::UnregisteredAuthor)
      @comment_token.presence || generate_token
    else
      nil
    end
  end

  # Private method generating token when unregistered user creates comment.
  # Token is saved with comment to enable editing it
  def generate_token
     SecureRandom.hex(rand(59))
  end
end
