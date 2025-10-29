# frozen_string_literal: true

Decidim::UserInterestsForm.class_eval do
  attribute :scopes_ids, [Integer]
  attribute :tags_ids, [Integer]
  attribute :follow_ngo, Decidim::AttributeObject::TypeMap::Boolean
  attribute :notifications_from_neighbourhood, Decidim::AttributeObject::TypeMap::Boolean
  attribute :zip_code
  attribute :organization
  attribute :scope_citywide, Decidim::AttributeObject::TypeMap::Boolean
  attribute :newsletter_notifications, Decidim::AttributeObject::TypeMap::Boolean
  attribute :email_on_notification, Decidim::AttributeObject::TypeMap::Boolean

  # overwritten method
  # add attrs
  def map_model(user)
    self.scopes = user.organization.scopes.top_level.map do |scope|
      Decidim::UserInterestScopeForm.from_model(scope:, user:)
    end

    # custom attrs
    self.organization = user.organization
    self.scopes_ids = user.extended_data["interested_scopes"]
    self.scope_citywide = Array(user.extended_data["interested_scopes"]).include?(Decidim::Scope.citywide.id)
    self.tags_ids = user.extended_data["interested_tags"]
    self.newsletter_notifications = user.newsletter_notifications_at.present?
    self.email_on_notification = user.email_on_notification
  end

  def available_scopes
    organization.scopes.district_only.top_level.map do |el|
      [el.name["pl"], el.id]
    end
  end

  def available_tags
    Decidim::AdminExtended::Tag.all.map do |el|
      [el.name, el.id]
    end
  end

  def newsletter_notifications_at
    return nil unless newsletter_notifications

    Time.current
  end
end
