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
      connect_src: [
        "'self'", "https://nominatim.um.warszawa.pl", "https://nominatim-test.um.warszawa.pl",
        "https://osm-test.um.warszawa.pl", "https://testmapa.um.warszawa.pl",
        'https://cdnjs.cloudflare.com',
        "https://*.googletagmanager.com", "https://*.google-analytics.com", "https://*.analytics.google.com",
        "https://*.g.doubleclick.net", "https://*.google.com", "ws:"],
      font_src: %w('self' data: http:),
      frame_src: %w('self' https://www.youtube.com https://www.youtube-nocookie.com),
      # Wylaczone zeby mozna bylo podgladac maile na localhost
      # frame_src: %w('none'),
      frame_ancestors: %w('self'),
      img_src: ["'self'", "data:", "http:", "https://#{ENV['AWS_STORAGE_ACCESS_BUCKET_NAME']}.s3.eu-central-1.amazonaws.com"],
      media_src: %w(http: 'self'),
      object_src: %w('none'),
      script_src: %w(* 'self' http: 'unsafe-inline' 'unsafe-eval'), # wlaczone wszystko dla better_error
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
      connect_src: ["'self'","ws:"],
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