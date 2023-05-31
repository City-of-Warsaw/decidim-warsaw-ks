if Rails.env.development?
  SecureHeaders::Configuration.default do |config|
    config.x_xss_protection = "0"
    # config.x_frame_options = "DENY"
    # config.x_download_options = "noopen" # Wylaczone zeby mozna bylo podgladac maile na localhost
    config.cookies = {
      secure: true, # mark all cookies as "Secure"
      httponly: true, # mark all cookies as "HttpOnly"
      samesite: {
        lax: true # mark all cookies as SameSite=lax
      }
    }
    config.csp = {
      default_src: %w(http: 'self'),
      font_src: %w('self' data: http:),
      frame_src: %w('self' https://www.youtube.com),
      # Wylaczone zeby mozna bylo podgladac maile na localhost
      # frame_src: %w('none'),
      # frame_ancestors: %w('none'),
      img_src: %w('self' http: data:),
      media_src: %w(http: 'self'),
      object_src: %w('none'),
      script_src: %w('self' http: 'unsafe-inline'),
      # script_src: %w('self' http:),
      # script_src: ["'self'", "https://#{ENV['MATOMO_HOST']}"],
      style_src: %w('self' http: 'unsafe-inline')
    }
  end

else
  SecureHeaders::Configuration.default do |config|
    config.x_xss_protection = "0"
    config.x_frame_options = "DENY"
    # config.x_download_options = "noopen"
    config.cookies = {
      secure: true, # mark all cookies as "Secure"
      httponly: true, # mark all cookies as "HttpOnly"
      samesite: {
        lax: true # mark all cookies as SameSite=lax
      }
    }
    # nowe-konsultacje.um.warszawa.pl
    config.csp = {
      default_src: %w(https: 'self'),
      font_src: %w('self' data: https:),
      frame_src: %w('self' https://www.youtube.com https://konsultacje.um.warszawa.pl https://nowe-konsultacje.um.warszawa.pl),
      frame_ancestors: %w('none' https://ks.testum.warszawa.pl https://ks-prep.um.warszawa.pl https://ks.beta-um.warszawa.pl https://nowe-konsultacje.um.warszawa.pl),
      img_src: %w('self' http: https: data: konsultacje.um.warszawa.pl nowe-konsultacje.um.warszawa.pl),
      object_src: %w('none'),
      script_src: ["'self'", "'unsafe-eval'", 'http://ks.testum.warszawa.pl', 'https://ks.testum.warszawa.pl', 'https://nowe-konsultacje.um.warszawa.pl', "https://#{ENV['MATOMO_HOST']}", "https://nominatim.cdsh.dev"],
      style_src: %w('self' https: 'unsafe-inline'),
      connect_src: ["'self'", 'http://ks.testum.warszawa.pl', 'https://ks.testum.warszawa.pl', 'https://nowe-konsultacje.um.warszawa.pl', "https://#{ENV['MATOMO_HOST']}", "https://nominatim.cdsh.dev"]
    }
  end
end