# frozen_string_literal: true

Decidim::PasswordsHelper.module_eval do
  def minimum_password_length
    # Devise.password_length.min
    # Decidim definiuje swoj wlasny validator
    ::PasswordValidator.minimum_length_for(Decidim::User.new)
  end
end