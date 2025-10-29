# frozen_string_literal: true

Decidim::Meetings::Meeting.class_eval do
  include Decidim::SanitizeHelper

  belongs_to :gallery, class_name: "Decidim::Repository::Gallery", optional: true

  has_many :email_follows,
           as: :followable,
           foreign_key: "decidim_followable_id",
           foreign_type: "decidim_followable_type",
           class_name: "Decidim::CoreExtended::EmailFollow",
           dependent: :destroy

  scope :current_and_upcoming, -> { where(arel_table[:start_time].lteq(Time.current).and(arel_table[:end_time].gteq(Time.current)).or(arel_table[:end_time].gteq(Time.current))) }
  scope :sorted_by_start_time, -> { order(start_time: :asc) }

  def main_scope
    participatory_space.scope
  end

  # public method
  # set location data:
  # - primary based on self data,
  # - secondly based on participatory space data,
  # - lastly on scope data
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

  # overwritten method
  # rebuild method
  # now check data from map locations
  def geocoded_and_valid?
    lat.present? && lng.present?
  end

  def found_address
    decidim_sanitize_translated(address) if address.present?
  end

  # Public: show address only for first location if there are more locations than one
  # `locations` is a Hash. If empty or nil, returns an empty string.
  #
  # @return [String]
  def address_simple
    return found_address.to_s.split(',').first if locations.blank? && found_address.present?

    first_loc = locations.values.first
    return "" if first_loc.blank? || first_loc["address"].blank?

    address = first_loc["address"]
    parts = [address["road"], address["house_number"]].compact.join(" ")
    location_pl = location["pl"].presence

    [parts, location_pl].compact.join(", ")
  end

  def coordinates_on_map
    arr = []
    if valid_coordinates?
      arr << {
        latitude: latitude,
        longitude: longitude,
        address: found_address
      }
    elsif participatory_space.geocoded_and_valid?
      arr << {
        latitude: participatory_space.latitude,
        longitude: participatory_space.longitude,
        address: participatory_space.address
      }
    else
      participatory_space.selected_scopes.each do |s|
        arr << {
          latitude: s.latitude,
          longitude: s.longitude,
          address: s.address
        }
      end
      arr
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
    elsif main_scope&.geocoded_and_valid?
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
    elsif main_scope&.geocoded_and_valid?
      main_scope.longitude
    end
  end

  # Public: checks if coordinates are valid
  #
  # returns: Boolean
  def valid_coordinates?
    latitude.present? && longitude.present? && !latitude&.nan? && !longitude&.nan?
  end

  # overwritten method
  # - used decidim particular meetings method
  # - participatory_space setting field: users_action_allowed_for_unregister_users
  def user_allowed_to_comment?(user)
    return false unless visible?
    return false unless published?
    return false unless accepts_new_comments?
    # scenario when registered user is present
    return true if user.present?

    # scenario when unregistered author is present
    participatory_space.users_action_allowed_for_unregister_users?
  end
end
