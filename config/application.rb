require_relative 'boot'

require "decidim/rails"
# Add the frameworks used by your app that are not loaded by Decidim.
# require "action_cable/engine"
# require "action_mailbox/engine"
# require "action_text/engine"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DecidimWarszawaKs
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Defaults from Rails 7
    config.active_storage.variable_content_types = %w(image/png image/gif image/jpeg image/tiff image/bmp image/vnd.adobe.photoshop image/vnd.microsoft.icon image/webp image/avif image/heic image/heif)

    config.after_initialize do
      if ActiveRecord::Base.connection.table_exists? 'decidim_admin_extended_banned_words'
        Obscenity::Base.blacklist = Decidim::AdminExtended::BannedWord.pluck(:name)
      end
    end
  end
end
