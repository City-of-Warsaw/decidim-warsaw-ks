# frozen_string_literal: true

# Class Decorator - Extending Decidim::Meetings::Meeting
#
# Decorator implements additional functionalities to the model
# and changes existing methods.
Decidim::Meetings::Meeting.class_eval do
  belongs_to :gallery, class_name: "Decidim::Repository::Gallery", optional: true

  def main_scope
    participatory_space.scope
  end

  # overitten method that will set location data primary based on
  # self data, secondly based on participatory space data, lastly
  # on scope data
  def to_coordinates
    if latitude.present? && longitude.present?
      super
    elsif participatory_space && participatory_space.latitude.present? && participatory_space.longitude.present?
      participatory_space.to_coordinates
    elsif main_scope && main_scope.latitude.present? && main_scope.longitude.present?
      main_scope.to_coordinates
    else
      [nil, nil]
    end
  end

  # overwritten
  # Public: checking if location data is available in
  # location searching tree.
  #
  # returns: Boolean
  def geocoded_and_valid?
    lat.present? && lng.present?
  end

  def found_address
    if address.present?
      address
    elsif participatory_space.geocoded_and_valid?
      participatory_space.address
    elsif main_scope.geocoded_and_valid?
      main_scope.address
    end
  end

  def address_simple
    if locations.first[1].present?
      "#{locations.first[1]["address"]["road"]}  #{locations.first[1]["address"]["house_number"]}"
    else
      found_address.split(',')[0]
    end
  end

  # Public: setting latitude value
  #
  # Method sets latitude value from location searching tree:
  # - self latitude data
  # - participatory space latitude data
  # - scope latitude data
  #
  # returns: Float
  def lat
    if valid_coordinates?
      latitude
    elsif participatory_space.geocoded_and_valid?
      participatory_space.latitude
    elsif main_scope.geocoded_and_valid?
      main_scope.latitude
    end
  end

  # Public: setting latitude value
  #
  # Method sets longitude value from location searching tree:
  # - self latitude data
  # - participatory space latitude data
  # - scope latitude data
  #
  # returns: Float
  def lng
    if valid_coordinates?
      longitude
    elsif participatory_space.geocoded_and_valid?
      participatory_space.longitude
    elsif main_scope.geocoded_and_valid?
      main_scope.longitude
    end
  end

  # Public: checks if coordinates are valid
  #
  # returns: Boolean
  def valid_coordinates?
    latitude.present? && longitude.present? && !latitude&.nan? && !longitude&.nan?
  end
end
