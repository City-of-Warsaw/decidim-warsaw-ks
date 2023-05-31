# frozen_string_literal: true

# OVERWRITTEN DECIDIM MODEL
# Model has been expanded with:
# - associations: to department, to gallery, has tags through
# - scopes - addictional filtering & sorting
# - changes existing methods mentioned above
Decidim::ParticipatoryProcess.class_eval do
  belongs_to :department,
             foreign_key: "decidim_department_id",
             class_name: "Decidim::AdminExtended::Department",
             optional: true

  belongs_to :gallery,
             class_name: "Decidim::Repository::Gallery",
             optional: true

  has_many :process_tags,
           class_name: "Decidim::ParticipatoryProcessesExtended::ProcessTag",
           foreign_key: :decidim_participatory_process_id,
           dependent: :destroy,
           inverse_of: :participatory_process

  has_many :tags,
           through: :process_tags,
           class_name: "Decidim::AdminExtended::Tag",
           source: :tag

  has_one :main_page_process,
          class_name: "Decidim::ParticipatoryProcessesExtended::MainPageProcess",
          foreign_key: "decidim_participatory_process_id",
          dependent: :destroy

  has_many :email_follows,
           as: :followable,
           foreign_key: "decidim_followable_id",
           foreign_type: "decidim_followable_type",
           class_name: "Decidim::CoreExtended::EmailFollow"

  has_many_attached :report_files

  geocoded_by :address

  scope :sorted_by_name, -> { order(name: :asc) }
  scope :active, -> { where(arel_table[:start_date].lteq(Date.current).and(arel_table[:end_date].gteq(Date.current))) }
  scope :latest_first, -> { order(created_at: :desc) }
  scope :on_main_page, -> { where(show_on_main_page: true) }
  scope :not_on_main_page, -> { where(show_on_main_page: false) }
  scope :order_for_main_page, -> { order(:main_page_weight) }

  # Public: method that returns year of process start for the search engine.
  # Years are user
  #
  # returns: Integer
  def self.years
    all.where.not(start_date: nil).order(start_date: :desc).map { |pp| pp.start_date&.year }.uniq
  end

  # Search processes in distance range. If process has blank lat and lng it is searching for his scope (district)
  # lat, lng - center point for searching in radius
  # distance - min distance radius in meters
  def self.in_range_from(lat, lng, distance = 2000.0)
    joins(:scope).where("
      (
        decidim_participatory_processes.latitude IS NOT NULL AND
        decidim_participatory_processes.longitude IS NOT NULL AND
        earth_distance(ll_to_earth(decidim_participatory_processes.latitude, decidim_participatory_processes.longitude), ll_to_earth(:lat, :lon)) < :distance
      ) OR (
        decidim_participatory_processes.latitude IS NULL AND
        decidim_participatory_processes.longitude IS NULL AND
        decidim_scopes.latitude IS NOT NULL AND
        decidim_scopes.longitude IS NOT NULL AND
        earth_distance(ll_to_earth(decidim_scopes.latitude, decidim_scopes.longitude), ll_to_earth(:lat, :lon)) < :distance
      )", lat: lat, lon: lng, distance: distance
    )
  end

  # Public: checking if location data is available in
  # location searching tree.
  #
  # returns: Boolean
  def geocoded_and_valid?
    latitude.present? && longitude.present?
  end

  # Public method that prevents rendering single file on gallery attachment partial
  def file
    false
  end

  # return users to notify
  # notifications_from_neighbourhood - z obszaru zainteresowac, w tym tez z okolicy
  # return Relation
  def find_possible_followers
    # TODO: dla maili:
    # .where(email_on_notification: true)
    followers.not_blocked.confirmed
  end

  # users to notify when process is publish only, filter based on interest
  # return Relation
  # TODO: brakuje wszystkich zainteresowan tagow z procesu, jest tylko pierwszy
  # TODO: brakuje wyszukiwania po zip_code
  def find_published_process_followers
    users = []
    users << Decidim::User.where(follow_ngo: true).pluck(:id) if recipients.in? ['ngo', 'mix']
    users << Decidim::User.where(notifications_from_neighbourhood: true).where("extended_data->'interested_scopes' @> :scope_id ", scope_id: scope.id.to_s).pluck(:id)
    tag_id = tag_ids.first # TODO: dodac wybranie wszystkich tagow
    users << Decidim::User.where(notifications_from_neighbourhood: true).where("extended_data->'interested_tags' @> :tag_id", tag_id: tag_id.to_s).pluck(:id) if tag_id

    Decidim::User.not_blocked.confirmed.where(id: users.flatten.uniq)
  end
end
