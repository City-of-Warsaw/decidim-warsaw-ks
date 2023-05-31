Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3000', '127.0.0.1:3000', 'localhost:3001', '127.0.0.1:3001', 'localhost:5000', '127.0.0.1:5000', '*.cdsh.dev',
            'ks.testum.warszawa.pl', 'ks.beta-um.warszawa.pl'
    resource '*',
             headers: :any,
             methods: %i(get post put patch delete options head)
  end
end