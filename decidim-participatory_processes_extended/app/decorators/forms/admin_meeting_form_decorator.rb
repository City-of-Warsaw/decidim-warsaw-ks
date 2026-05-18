# frozen_string_literal: true

Decidim::Meetings::Admin::MeetingForm.class_eval do
  include Decidim::Repository::Admin::GalleryInputAttributes
  include Decidim::Repository::Admin::GalleriesValidations

  attribute :locations_json, Hash, default: "{}"
  attribute :title_description, String
  attribute :title_services, String

  # overwritten validations
  # remove standard validators - customer do not want them
  _validators[:description].clear
  _validators[:location].clear
  _validators[:comments_start_time].clear
  _validators[:comments_end_time].clear

  # overwritten validations
  # remove validator callbacks - customer do not want them
  _validate_callbacks.each do |callback|
    filter = callback.filter

    filter.attributes.delete(:description) if filter.is_a?(TranslatablePresenceValidator)
    filter.attributes.delete(:location) if filter.is_a?(TranslatablePresenceValidator)
    filter.attributes.delete(:comments_start_time) if filter.is_a?(ActiveModel::Validations::DateValidator)
    filter.attributes.delete(:comments_end_time) if filter.is_a?(ActiveModel::Validations::DateValidator)
  end

  validate :address_was_geocoded
  validate :location_was_filled

  def location_was_filled
    if hybrid_meeting? || in_person_meeting?
      errors.add(:location, "Nie może być puste") if address_data_and_location_blank?
    end
  end

  def address_was_geocoded
    if hybrid_meeting? || in_person_meeting?
      errors.add(:locations_json, "Należy podać adres") if address_data_and_location_blank?
    end
  end

  # Public method for hybrid_meeting address_was_geocoded
  # returns Boolean
  def address_data_blank?
    locations_data.empty? ||
      parse_locations.empty? ||
      parse_locations["lat"].blank? ||
      parse_locations["lng"].blank?
  end

  # Public method for in person meeting address_was_geocoded and location_was_filled
  # returns Boolean
  def address_data_and_location_blank?
    (locations_data.empty? && location[:pl].blank?) ||
      (parse_locations.empty? && location[:pl].blank?) ||
      (parse_locations["lat"].blank? && location[:pl].blank?) ||
      (parse_locations["lng"].blank? && location[:pl].blank?)
  end

  # Public method parsing locations Hash and returning Hash
  # with first address data
  #
  # returns Hash
  def parse_locations
    locations_data.values.first || {}
  end

  # Public functions that parse data from the view into json format
  #
  # returns Hash
  def locations_data
    return {} if locations_json.blank?

    JSON.parse(locations_json)
  end

  # overwritten method
  # set it always to false
  # reason: overwritten validations
  def geocoding_enabled?
    false
  end

  # overwritten method
  # reason: overwritten validations
  def needs_address?
    false
  end

  # overwritten method
  # order meeting services via order id
  # add gallery
  # add locations
  def map_model(model)
    self.services = model.services.order(:id).map do |service|
      Decidim::Meetings::Admin::MeetingServiceForm.from_model(service)
    end

    self.decidim_category_id = model.categorization.decidim_category_id if model.categorization
    self.type_of_meeting = model.type_of_meeting

    presenter = Decidim::Meetings::MeetingPresenter.new(model)
    self.title = presenter.title(all_locales: title.is_a?(Hash))
    self.description = presenter.description(all_locales: description.is_a?(Hash))

    # custom attrs
    self.gallery_id = model.gallery_id
    self.locations_json = model.locations.to_json
  end

  # overwritten method
  # set registration_type to :registration_disabled
  # reason: hide the field
  def registration_type
    "registration_disabled"
  end

  # overwritten form field
  # set it always to true
  # reason: hide the field
  def transparent
    true
  end

  # overwritten form field
  # set it always to false
  # reason: hide the field
  def private_meeting
    false
  end
end
