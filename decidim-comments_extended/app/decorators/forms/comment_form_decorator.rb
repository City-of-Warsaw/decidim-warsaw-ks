# frozen_string_literal: true
require 'obscenity/active_model'

Decidim::Comments::CommentForm.class_eval do
  attribute :signature, String
  attribute :comment
  attribute :files, [String]

  validates :signature,
            obscenity: { message: :banned_word_in_name }

  validates :body, obscenity: { message: :banned_word }

  def max_depth
    return unless commentable.respond_to?(:depth)

    errors.add(:base, :invalid) if commentable.depth >= Decidim::Comments::Comment.const_get(:NEW_MAX_DEPTH)
  end

  def map_model(model)
    super

    self.body = model.body['pl']
    self.comment = model
  end
end
