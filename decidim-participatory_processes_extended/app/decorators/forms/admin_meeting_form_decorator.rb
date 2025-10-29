# frozen_string_literal: true

Decidim::Meetings::Admin::MeetingForm.class_eval do
  include Decidim::Repository::Admin::GalleryInputAttributes
  include Decidim::Repository::Admin::GalleriesValidations

  attribute :locations_json, Hash, default: "{}"
  attribute :title_description, String
  attribute :title_services, String

  # overwritten validations
  # use our approach
  clear_validators!

  validates :title, translatable_presence: true
  validates :registration_type, presence: true
  validates :registration_url, presence: true, url: true, if: ->(form) { form.on_different_platform? }
  validates :type_of_meeting, presence: true
  validates :address, presence: true, if: ->(form) { form.needs_address? }
  validates :address, geocoding: true, if: ->(form) { form.has_address? && !form.geocoded? && form.needs_address? }
  validates :online_meeting_url, presence: true, if: ->(form) { form.online_meeting? || form.hybrid_meeting? }
  validates :start_time, presence: true, date: { before: :end_time }
  validates :end_time, presence: true, date: { after: :start_time }
  validates :current_component, presence: true
  validates :category, presence: true, if: ->(form) { form.decidim_category_id.present? }
  validates :scope, presence: true, if: ->(form) { form.decidim_scope_id.present? }
  validates :decidim_scope_id, scope_belongs_to_component: true, if: ->(form) { form.decidim_scope_id.present? }
  validates :clean_type_of_meeting, presence: true
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
