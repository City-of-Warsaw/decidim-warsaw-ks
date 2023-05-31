# frozen_string_literal: true

# OVERWRITTEN DECIDIM FORM
# Class Decorator - Extending Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessForm
#
# Form has been expanded with:
# - filename changed:
#     from: participatory_process_form.rb
#     to: admin_participatory_process_form_decorator.rb
# - changes existing methods
# - new attributes: fb_url, department_id, recipients, tags, consultation_status, address, latitude, longitude, locations_json
# gallery_id, report_description, report_publication_date, report_notification_send, report_change_status,report_files_input
# - added new methods
Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessForm.class_eval do
  RECIPIENTS = %w(citizens ngo mix).freeze
  CONSULTATION_STATUSES = %w(report effects).freeze

  attribute :fb_url, String
  attribute :department_id, Integer
  attribute :recipients, String
  attribute :consultation_status, String
  # attribute :address, String
  # attribute :latitude, Float
  # attribute :longitude, Float
  attribute :locations_json, Hash
  attribute :gallery_id, Integer
  attribute :report_description, String
  attribute :report_publication_date, Decidim::Attributes::LocalizedDate
  attribute :report_notification_send, Virtus::Attribute::Boolean
  attribute :report_change_status, Virtus::Attribute::Boolean # this field is only for Form it does not exist in process
  attribute :tag_ids, Array
  attribute :hero_image_alt, String
  attribute :report_files, [String]
  attribute :remove_report_ids, [Integer]
  attribute :users_action_allowed_for_unregister_users, Virtus::Attribute::Boolean

  attribute :report_files_input, [String]

  validate :address_was_geocoded, if: proc { |attr| locations_data.any? }
  validate :fb_url_is_facebook_event, if: proc { |attr| fb_url.present? }
  validates :recipients, presence: true, inclusion: { in: RECIPIENTS }
  validates :consultation_status, inclusion: { in: CONSULTATION_STATUSES }, if: proc { |attr| attr[:consultation_status].present? }
  validates :scope_id, presence: true
  validates :area_id, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :hero_image, presence: true
  validates :users_action_allowed_for_unregister_users, presence: true

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

  # OVERWRITTEN DECIDIM METHOD
  #
  # Method adds mapping for department association
  #
  # returns object - Decidim::ParticipatoryProcess
  def map_model(model)
    self.area_id = model.decidim_area_id
    self.scope_id = model.decidim_scope_id
    self.department_id = model.decidim_department_id
    self.participatory_process_group_id = model.decidim_participatory_process_group_id
    self.related_process_ids = model.linked_participatory_space_resources(:participatory_process, 'related_processes').pluck(:id)
    self.locations_json = model.locations.to_json
    self.hero_image_alt = model.hero_image_alt
    self.report_files = model.report_files
    @processes = Decidim::ParticipatoryProcess.where(organization: model.organization).where.not(id: model.id)
  end

  # Public: returns mapped list of recipients for form.
  #
  # returns: Array
  def type_of_recipients
    RECIPIENTS.map do |recipient|
      [
        I18n.t("recipients_type.#{recipient}", scope: 'decidim.participatory_processes'),
        recipient
      ]
    end
  end

  # Public: returns mapped list of consultation_statuses for form.
  #
  # returns: Array
  def consultation_statuses
    CONSULTATION_STATUSES.map do |status|
      [
        I18n.t("consultation_statuses.#{status}", scope: 'decidim.participatory_processes'),
        status
      ]
    end
  end

  # Public: returns mapped list of departments for form.
  #
  # returns: Array
  def departments_for_select
    Decidim::AdminExtended::Department.all.map { |department| [department.name, department.id] }
  end

  # Public validation function that checks presence && compliant of facebook link
  # It adds Error message on fb url field
  #
  # returns nothing
  def fb_url_is_facebook_event
    uri = URI.parse(fb_url)
    unless uri.is_a?(URI::HTTP) && !uri.host.nil? && uri.to_s.include?('https://www.facebook.com/events/')
      errors.add(:fb_url, 'Niewłaściwy link do wydarzenia na Facebooku')
    end
  rescue URI::InvalidURIError
    errors.add(:fb_url, 'Niewłaściwy link do wydarzenia na Facebooku')
  end

  # # Public: checking if geocoding is implemented
  # # and if address params are present.
  # #
  # # returns: Boolean
  # def has_address?
  #   geocoding_enabled? && address.present?
  # end
  #
  # # Public: checking if latitude and longitude were geocoded.
  # #
  # # Geocoder sets NaN value for empty address.
  # #
  # # returns: Boolean
  # def geocoded?
  #   # geocoder sets NaN when no address given
  #   latitude.present? && longitude.present? && !latitude&.nan? && !longitude&.nan?
  # end
  #
  # # Public: checking if geocoding is implemented.
  # #
  # # returns: Boolean
  # def geocoding_enabled?
  #   Decidim::Map.available?(:geocoding)
  # end

  def department
    current_organization.departments.find_by(id: department_id)
  end

  # Public method that overwrites subtitle with title value.
  # This project does not use subtitle
  #
  # returns Hash
  def subtitle
    title
  end

  # Public method that overwrites scopes_enabled with true value.
  # This project always applies scope
  def scopes_enabled
    true
  end

  # Public method that overwrites private space with false value.
  # This project does not use private spaces
  def private_space
    false
  end

  # Public method that overwrites show_metrics with false value.
  # This project does not use private spaces
  def show_metrics
    false
  end

  # Public method that overwrites show_statistics with false value.
  # This project does not use private spaces
  def show_statistics
    false
  end
end
