# frozen_string_literal: true

Decidim::Comments::Permissions.class_eval do

  private

  def can_create_comment?
    return disallow! unless commentable.commentable?
    return disallow! unless commentable&.user_allowed_to_comment?(user)
    return disallow! if commentable.respond_to?(:participatory_space) && commentable.participatory_space && commentable&.participatory_space.private_space? && !user

    allow!
  end
end
