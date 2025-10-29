# frozen_string_literal: true

if Rails.env.staging?
  require 'interceptors/staging_email_interceptor'

  ActionMailer::Base.register_interceptor(Interceptors::StagingEmailInterceptor)
end