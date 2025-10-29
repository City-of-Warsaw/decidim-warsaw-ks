# frozen_string_literal: true

require "obscenity/active_model"

Decidim::AccountForm.class_eval do
  include Decidim::UserProfilableCollections

  clear_validators!

  attribute :gender
  attribute :birth_year
  attribute :district_id
  attribute :zip_code

  validates :name, length: { maximum: Decidim::User.nickname_max_length }
  validates :email, presence: true, "valid_email_2/email": { disposable: true }
  validates :password, password: { name: :name, email: :email, username: :nickname }, if: -> { password.present? }
  validate :validate_old_password
  validates :avatar,
            passthru: { to: Decidim::User },
            file_size: { less_than_or_equal_to: Decidim.config.maximum_avatar_size }

  validate :unique_email
  validate :unique_nickname

  validates :birth_year, numericality: { only_integer: true, greater_than: 1899, less_than: Date.current.year, allow_nil: true }, if: proc { |attr| attr[:birth_year].present? }
  validates :zip_code, allow_blank: true, allow_nil: true, format: { with: /\A[0-9]{2}-[0-9]{3}\z/ }
  validates :name, obscenity: { message: :banned_word_in_name }

  def map_model(user)
    super

    self.district_id = user.main_scope_id
  end

  def nickname
    loop do
      random_nickname = "user-#{rand(Time.current.to_i)}"
      break random_nickname unless Decidim::User.exists?(nickname: random_nickname)
    end
  end
end
