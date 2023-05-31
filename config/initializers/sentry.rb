Sentry.init do |config|
  config.dsn = 'https://54a63791adf04c1382600de16f4185a7@o140295.ingest.sentry.io/4504213061959680'  unless Rails.env.development?
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 0.05
  # or
  # config.traces_sampler = lambda do |context|
  #   true
  # end
end
# TEST message:
# Sentry.capture_message("test message from dev")