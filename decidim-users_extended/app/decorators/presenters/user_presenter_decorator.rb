# frozen_string_literal: true

Decidim::UserPresenter.class_eval do

  def can_be_contacted?
    false
  end

  def can_follow?
    false
  end

  def has_tooltip?
    false
  end
end