# frozen_string_literal: true

# OVERWRITTEN DECIDIM FORM
# The form object to update the current user interests form the user account
# Class has been provided with attributes to map data
#
# Public: mapping of Users interests.
# Form has been expanded with:
# - attributes
# - an additional block for the method: map model(user) to map those additional attributes
Decidim::UserInterestsForm.class_eval do
  # overwritten
  attribute :scopes_ids, Array[Integer]
  attribute :tags_ids, Array[Integer]
  attribute :follow_ngo, Virtus::Attribute::Boolean
  attribute :notifications_from_neighbourhood, Virtus::Attribute::Boolean
  attribute :zip_code
  attribute :organization

  def map_model(user)
    self.organization = user.organization
    self.scopes_ids = user.extended_data["interested_scopes"]
    self.tags_ids = user.extended_data["interested_tags"]
  end

  def available_scopes
    organization.scopes.top_level.map do |el|
      [el.name["pl"], el.id]
    end
  end

  def available_tags
    organization.tags.map do |el|
      [el.name, el.id]
    end
  end

end