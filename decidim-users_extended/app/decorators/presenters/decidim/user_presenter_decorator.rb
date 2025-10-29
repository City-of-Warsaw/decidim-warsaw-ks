# frozen_string_literal: true

Decidim::UserPresenter.class_eval do
  # overwritten method
  # set always false
  def can_be_contacted?
    false
  end

  # overwritten method
  # set always false
  def can_follow?
    false
  end

  # overwritten method
  # set always false
  def has_tooltip?
    false
  end

  # overwritten
  # for AD user with editorial or signature - that should be displayed in comments
  # tip: comments in process and search are display by different cells
  def avatar_url(variant = nil)
    return default_avatar_url if __getobj__.blocked?
    return default_avatar_url unless avatar.attached?
    return default_avatar_url if __getobj__.respond_to?(:editorial) && __getobj__.editorial.present?

    avatar.url(variant:)
  end
end
