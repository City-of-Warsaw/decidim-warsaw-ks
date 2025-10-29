Decidim::NewsletterEncryptor.class_eval do
  # OVERWRITTEN DECIDIM METHOD
  #
  # Method to create string encrypt using email and resorce of newsletter to unsubscribe's user
  def self.sent_at_encrypted(user_id, resource_type, source_type)
    crypt_data.encrypt_and_sign("#{user_id}-#{resource_type}-#{source_type}")
  end

  # Method to decrypt sent_at newsletter.
  def self.sent_at_decrypted(string_encrypted)
    crypt_data.decrypt_and_verify(string_encrypted)
  end

  # Method for decrypt data from string - there is no time (sent_at) to check for this link
  def self.decrypt_data(string_encrypted)
    crypt_data.decrypt_and_verify(string_encrypted)
  end

  def self.crypt_data
    key = ActiveSupport::KeyGenerator.new('unsubscribe').generate_key(
      Rails.application.secrets.secret_key_base, ActiveSupport::MessageEncryptor.key_len
    )
    ActiveSupport::MessageEncryptor.new(key)
  end
end