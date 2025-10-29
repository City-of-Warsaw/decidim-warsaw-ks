# frozen_string_literal: true

Decidim::FollowButtonCell.class_eval do
  include Decidim::CoreExtended::UrlHelper

  # overwritten method - view
  # render also email follow for unregistered user
  def show
    render :show_new
  end

  # overwritten method
  # we do not use followers of users
  # just use column follows count
  def followers_count
    model.follows_count
  end
end
