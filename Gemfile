# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", '0.29.3'
gem "decidim-design"

gem "bootsnap"

gem "puma", ">= 6.3.1"

gem "valid_email2"

# Neededd for admin sortable
gem 'jquery-ui-rails'

# Deployment
gem 'mina'
gem 'sitemap_generator'
gem 'dotenv-rails'
gem 'sidekiq'

# Http client for PEUM service
gem 'http'

# Security
gem 'brakeman', require: false
gem "faker"
# Active directory
gem 'net-ldap'

# sentry.io
gem "sentry-ruby"
gem "sentry-rails"

# Export to Excel
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# sending notifications when errors occur
gem 'exception_notification'

# fix SameSite = none
# gem 'rails_same_site_cookie'
gem 'secure_headers'

# logging system
gem 'lograge'

gem 'awesome_print'

# obsluga SOAP dla Signum
gem "savon", '2.15.1'

# Do obslugi wulgaryzmow
gem 'obscenity', '1.0.2'

# barcodes
gem 'barby'
gem 'chunky_png'

# for writing and deploying cron jobs.
gem 'whenever', require: false
gem 'i18n-active_record'
group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "pry-byebug"
  gem "pry-rails"
  gem "decidim-dev", '0.29.3'
  gem 'email_spec', '~> 2.2'
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "web-console", "~> 4.2"
  gem "yard", require: false
end

group :production, :staging do
  gem "mina-sidekiq"
  gem 'rack_password'
end

# custom Decidim extensions
gem 'decidim-admin_extended', path: 'decidim-admin_extended'
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
gem 'decidim-custom_proposals', path: 'decidim-module-custom_proposals'
gem 'decidim-general_plan_requests', path: 'decidim-module-general_plan_requests'

# Rest API
gem 'active_model_serializers'
gem 'decidim-rest_api', path: 'decidim-module-rest_api'
gem "aws-sdk-s3", "~> 1.199"
