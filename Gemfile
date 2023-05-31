# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", "0.24.3"

gem "bootsnap", "1.7.4"

gem "puma", ">= 5.0.0"
# gem "uglifier", "~> 4.1"
gem "terser"

gem "faker", "~> 2.14"

gem "wicked_pdf", "~> 1.4"

gem "valid_email2", "~> 2.1"

# Neededd for admin sortable
gem 'jquery-ui-rails'

# Deployment
gem 'mina'
gem 'dotenv-rails'

# Http client for PEUM service
gem 'http'

# Security
gem 'brakeman', require: false

# Active directory
gem 'net-ldap'

# sentry.io
gem "sentry-ruby"
gem "sentry-rails"

# Export to Excel
gem 'caxlsx'
gem 'caxlsx_rails'

# sending notifications when errors occur
gem 'exception_notification'

# fix SameSite = none
# gem 'rails_same_site_cookie'
gem 'secure_headers'

# logging system
gem 'lograge'

gem 'awesome_print'

# Do obslugi wulgaryzmow
gem 'obscenity', '1.0.2'

# for writing and deploying cron jobs.
gem 'whenever', require: false

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", "0.24.3"
  # gem "decidim-dev", "0.26.1"
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
  gem "yard", require: false
end

# custom Decidim extensions
gem 'decidim-admin_extended', path: 'decidim-admin_extended'
gem 'decidim-comments_extended', path: 'decidim-comments_extended'
gem 'decidim-core_extended', path: 'decidim-core_extended'
gem 'decidim-pages_extended', path: 'decidim-pages_extended'
gem 'decidim-participatory_processes_extended', path: 'decidim-participatory_processes_extended'
gem 'decidim-users_extended', path: 'decidim-users_extended'

gem 'decidim-ad_users_space', path: 'decidim-ad_users_space'
gem 'decidim-consultation_map', path: 'decidim-consultation_map'
gem 'decidim-consultation_requests', path: 'decidim-consultation_requests'
gem 'decidim-expert_questions', path: 'decidim-expert_questions'
gem 'decidim-news', path: 'decidim-news'
gem 'decidim-remarks', path: 'decidim-remarks'
gem 'decidim-ws_notification', path: 'decidim-module-ws_notification'
gem 'decidim-repository', path: 'decidim-module-repository'
gem 'decidim-study_notes', path: 'decidim-module-study_notes'

# Rest API
gem 'active_model_serializers'
gem 'decidim-rest_api', path: 'decidim-module-rest_api'