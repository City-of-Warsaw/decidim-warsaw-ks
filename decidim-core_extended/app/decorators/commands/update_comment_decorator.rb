# frozen_string_literal: true

Decidim::Comments::UpdateComment.class_eval do
  private

  # overwritten method
  # add scenario if current user is unregistered author
  # add to params files and remove files
  def update_comment
    parsed = Decidim::ContentProcessor.parse(form.body, current_organization: form.current_organization)

    params = {
      body: { I18n.locale => parsed.rewrite },
      files: merged_files
    }

    if current_user.is_a?(Decidim::User)
      @comment = Decidim.traceability.update!(
        comment,
        current_user,
        params,
        visibility: "public-only",
        edit: true
      )
    else
      # custom:
      # - when current user is unregistered author
      # - manually create log
      @comment.update(params)

      Decidim::ActionLog.create!(
        decidim_organization_id: @comment.root_commentable.organization.id,
        decidim_user_id: unregistered_author.id,
        resource: @comment,
        action: "update",
        visibility: "public-only",
        extra: {
          edit: true,
          source: "unregistered_comment_edit",
          unregistered_author: { token: @comment.token }
        },
        created_at: Time.current,
        updated_at: Time.current
      )
    end

    Decidim::Comments::CommentCreation.publish(@comment, parsed.metadata)
  end

  # Private method
  # returns updated files list with current/new/removed ones
  def merged_files
    to_remove_ids = form.remove_files.map(&:to_i)
    existing_blobs = comment.files.reject { |f| to_remove_ids.include?(f.id) }.map(&:blob)
    new_files = Array(form.files)

    existing_blobs + new_files
  end

  # Private method
  # returns special object that serves as Author for comments created by unregistered users
  def unregistered_author
    @unregistered_author ||= Decidim::CoreExtended::UnregisteredAuthor.first
  end
end
