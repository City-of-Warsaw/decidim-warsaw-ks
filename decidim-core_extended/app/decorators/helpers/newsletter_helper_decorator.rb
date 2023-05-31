# frozen_string_literal: true

Decidim::NewslettersHelper.class_eval do
  # Overwritten, missing proper host from action_mailer.asset_host config
  def image_tag(source, options = {})
    ActionController::Base.helpers.image_tag(image_url(source, host: Rails.application.config.action_mailer.asset_host), options)
  end
end