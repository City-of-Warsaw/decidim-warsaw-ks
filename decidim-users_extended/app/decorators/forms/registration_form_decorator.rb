# frozen_string_literal: true

require 'obscenity/active_model'

Decidim::RegistrationForm.class_eval do
  include Decidim::UserProfilableCollections

  attribute :gender
  attribute :birth_year
  attribute :district_id
  # notifications
  attribute :notifications_from_neighbourhood, Virtus::Attribute::Boolean
  attribute :newsletter_notifications, Virtus::Attribute::Boolean
  attribute :follow_ngo, Virtus::Attribute::Boolean
  # interests
  attribute :scopes_ids, Array[Integer]
  attribute :tags_ids, Array[Integer]
  attribute :zip_code

  validates :birth_year, numericality: { only_integer: true, greater_than: 1899, less_than_or_equal_to: Date.current.year, allow_nil: true }, if: proc { |attr| attr[:birth_year].present? }
  validates :zip_code, allow_blank: true, allow_nil: true, format: { with: /\A[0-9]{2}-[0-9]{3}\z/ }
  validates :name, obscenity: { message: :banned_word_in_name }
  validates :gender, inclusion: %w[male female other], allow_blank: true
  validates :district_id, numericality: true, allow_blank: true

  def nickname
    generated_nickname = loop do
      random_nickname = "user-#{rand(Time.current.to_i)}"
      break random_nickname unless Decidim::User.exists?(nickname: random_nickname)
    end
    generated_nickname
  end

  alias organization current_organization

  def available_scopes
    Decidim::Scope.all.map do |el|
      [translated_attribute(el.name), el.id]
    end
  end

  def picked_scopes
    scopes_ids.reject(&:blank?)
  end

  def picked_tags
    tags_ids.reject(&:blank?)
  end

  def available_tags
    Decidim::AdminExtended::Tag.all.map do |el|
      [translated_attribute(el.name), el.id]
    end
  end

  # Public method mapping notification types
  # Copied from Decidim::NotificationsSettingsForm
  #
  # Returns String
  def notification_types
    if notifications_from_followed && notifications_from_own_activity
      "all"
    elsif notifications_from_followed
      "followed-only"
    elsif notifications_from_own_activity
      "own-only"
    else
      "none"
    end
  end
end
