# frozen_string_literal: true

# Class Decorator - Extending Decidim::Meetings::Admin::MeetingForm
#
# Decorator implements additional functionalities
# and changes existing methods.
#
# Implements new attributes:
# - locations_json
Decidim::Meetings::Admin::MeetingForm.class_eval do
  attribute :gallery_id, Integer
  attribute :locations_json, Hash

  validate :address_was_geocoded, if: ->(form) { form.in_person_meeting? || form.hybrid_meeting? }

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

  # OVERWRITTEN Public method
  #
  # Blocking Decidim geocoding mechanism and using custom one
  #
  # returns Boolean
  def geocoding_enabled?
    false
  end

  # OVERWRITTEN Public method
  #
  # Validation that blocks Decidim geocoding mechanism
  #
  # returns Boolean
  def needs_address?
    false
  end

  # Public function mapping meeting data on form data
  #
  # returns noting
  def map_model(model)
    self.services = model.services.map do |service|
      Decidim::Meetings::Admin::MeetingServiceForm.from_model(service)
    end

    self.decidim_category_id = model.categorization.decidim_category_id if model.categorization
    presenter = Decidim::Meetings::MeetingPresenter.new(model)

    self.title = presenter.title(all_locales: title.is_a?(Hash))
    self.description = presenter.description(all_locales: description.is_a?(Hash))
    self.type_of_meeting = model.type_of_meeting
    # custom mapping
    self.locations_json = model.locations.to_json
  end

  # Public method setting registration_type to :registration_disabled so the field can be hidden
  def registration_type
    'registration_disabled'
  end

  # Public method setting transparent to true so the field can be hidden
  def transparent
    true
  end

  # Public method setting private_meeting to false so the field can be hidden
  def private_meeting
    false
  end
end
