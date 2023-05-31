# frozen_string_literal: true

# Class Decorator - Extending Decidim::Admin::ScopeForm
#
# Decorator implements additional functionalities
# and changes existing methods.
#
# Implements new attributes:
# - latitude
# - longitude
# - locations_json
Decidim::Admin::ScopeForm.class_eval do
  # attribute :latitude, Float
  # attribute :longitude, Float
  attribute :locations_json, Hash

  validate :address_was_geocoded

  # Public validation function that checks if address was provided and with proper data.
  # It adds Error message on address field
  #
  # returns nothing
  def address_was_geocoded
    if locations_data.empty? ||
      parse_locations.empty? ||
      parse_locations['lat'].blank? ||
      parse_locations['lng'].blank?

      errors.add(:locations_json, 'Należy podać adres')
    end
  end

  # Public method parsing locations Hash and returning Hash
  # with first address data
  #
  # returns Hash
  def parse_locations
    arr = locations_data.map { |k, v| v }

    arr[0]
  end

  # Public functions that parse data from the view into json format
  #
  # returns Hash
  def locations_data
    JSON.parse(locations_json)
  end

  # Public function mapping scope data on form data
  #
  # returns noting
  def map_model(model)
    super

    self.locations_json = model.locations.to_json
  end
end