Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.active_job.queue_adapter = :sidekiq

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  config.action_controller.asset_host = ENV.fetch("ASSET_HOST") { 'https://konsultacje.um.warszawa.pl' }

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local
  # config.active_storage.service = :amazon

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true
  config.force_ssl = false

  # https://github.com/rails/rails/issues/22965
  config.action_controller.forgery_protection_origin_check = false

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = %w(debug info warn error fatal).include?(ENV['RAILS_LOG_LEVEL']) ? ENV['RAILS_LOG_LEVEL'] : :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "decidim_warszawa_ks_#{Rails.env}"

  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: 'https://konsultacje.um.warszawa.pl', protocol: 'https' }
  config.action_mailer.asset_host = 'https://konsultacje.um.warszawa.pl'

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new
  config.action_mailer.smtp_settings = {
    :address        => Rails.application.secrets.smtp_address,
    :port           => Rails.application.secrets.smtp_port,
    :authentication => Rails.application.secrets.smtp_authentication,
    :user_name      => Rails.application.secrets.smtp_username,
    :password       => Rails.application.secrets.smtp_password,
    :domain         => Rails.application.secrets.smtp_domain,
    :enable_starttls_auto => Rails.application.secrets.smtp_starttls_auto,
    :openssl_verify_mode => 'none'
  }

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  if ENV["SITE_PASSWORD"].present?
    # Block users that do not know a given password
    config.middleware.use RackPassword::Block, auth_codes: [ENV["SITE_PASSWORD"]]
  end
end
