Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :letter_opener_web
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.perform_deliveries = true
  config.action_mailer.default_url_options = { host: 'http://localhost', port: 3000 }
  config.action_mailer.asset_host = 'http://localhost:3000' # this does not work in cells
  # This work in newsletter templates, but it is problematic:
  # config.action_controller.asset_host = 'http://localhost3:3000'

  config.action_mailer.perform_caching = false

  config.action_mailer.smtp_settings = {
    :address        => ENV.fetch("SMTP_ADDRESS"),
    :port           => ENV.fetch("SMTP_PORT") { 587 },
    :authentication => ENV.fetch("SMTP_AUTHENTICATION") { 'login' },
    :user_name      => ENV.fetch("SMTP_USERNAME"),
    :password       => ENV.fetch("SMTP_PASSWORD"),
    :domain         => ENV.fetch("SMTP_DOMAIN"),
    :enable_starttls_auto => false,
    :openssl_verify_mode => 'none'
  }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # No precompilation on demand on first request
  config.assets.check_precompiled_asset = false

  # Lograge config
  config.lograge.enabled = true
  config.lograge.ignore_actions = [
    "ActiveStorage::DiskController#show",
    "ActiveStorage::RepresentationsController#show",
    "ActiveStorage::Representations::RedirectController#show",
    "ActiveStorage::BlobsController#show"
  ]
  # add time to lograge and params
  config.lograge.custom_options = lambda do |event|
    exceptions = %w(controller action format)
    {
      params: event.payload[:params].except(*exceptions),
      time: Time.now
    }
  end
  # to keep the original (and verbose) Rails logger:
  # config.lograge.keep_original_rails_log = true
  # config.lograge.logger = ActiveSupport::Logger.new "#{Rails.root}/log/lograge_#{Rails.env}.log"
end
