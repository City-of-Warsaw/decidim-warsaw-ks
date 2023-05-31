# frozen_string_literal: true

Decidim::CreateFollow.class_eval do
  # Overwritten Decidim method:
  # Executes the command. Broadcasts these events:
  #
  # - :ok when everything is valid, together with the follow.
  # - :invalid if the form wasn't valid and we couldn't proceed.
  # - :invalid if followable is a user to prevent globally following users
  #
  # Returns nothing.
  def call
    return broadcast(:invalid) if form.followable.is_a?(Decidim::User) || form.followable.is_a?(Decidim::UserBaseEntity)
    return broadcast(:invalid) if form.invalid?

    create_follow!
    increment_score

    broadcast(:ok, follow)
  end
end
