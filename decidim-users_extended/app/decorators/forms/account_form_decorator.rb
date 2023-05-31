# frozen_string_literal: true

require 'obscenity/active_model'

# OVERWRITTEN DECIDIM FORM
# A form object used to update the current logged user from user panel
# Class was provided with attributes for adding more personal information about current user, to /account
# Form was expanded with:
# attributes: gender, birth year, district id, zip code
# validations for birth year, zip code
Decidim::AccountForm.class_eval do
  include Decidim::UserProfilableCollections

  attribute :gender
  attribute :birth_year
  attribute :district_id
  attribute :zip_code

  validates :birth_year, numericality: { only_integer: true, greater_than: 1899, less_than: Date.current.year, allow_nil: true }, if: proc { |attr| attr[:birth_year].present? }
  validates :zip_code, allow_blank: true, allow_nil: true, format: { with: /\A[0-9]{2}-[0-9]{3}\z/ }
  validates :name, obscenity: { message: :banned_word_in_name }

  def map_model(user)
    super
    self.district_id = user.main_scope_id
  end

  def nickname
    generated_nickname = loop do
      random_nickname = "user-#{rand(Time.current.to_i)}"
      break random_nickname unless Decidim::User.exists?(nickname: random_nickname)
    end
    generated_nickname
  end
end
