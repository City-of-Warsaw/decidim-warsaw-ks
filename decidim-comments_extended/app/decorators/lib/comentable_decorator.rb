# frozen_string_literal: true

Decidim::Comments::Commentable.module_eval do

  # new method to allow commenting
  def allowed_to_comment?(user)
    return self.comments_allowed if self.class.name == 'Decidim::ConsultationRequests::ConsultationRequest'

    !component&.participatory_space.try(:private_space?) ||
      (user && component&.participatory_space.can_participate?(user))
  end

  # when commentable is a Comment
  def unregistered_author?
    decidim_author_type == Decidim::CommentsExtended::UnregisteredAuthor.name
  end
end
