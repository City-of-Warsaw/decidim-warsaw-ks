# This will make the verifier fallback to reading old URLs from Rails 6.1
Rails.application.config.after_initialize do |app|
  old_secret_key_base = ENV['OLD_SECRET_KEY_BASE'] || Rails.application.credentials.dig(:old_secret_key_base)
  next if old_secret_key_base.blank?

  key_generator = ActiveSupport::KeyGenerator.new(old_secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1)
  secret = key_generator.generate_key("ActiveStorage")
  app.message_verifier("ActiveStorage").rotate(secret)
end