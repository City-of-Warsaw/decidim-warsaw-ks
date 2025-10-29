# frozen_string_literal: true

Decidim::ParticipatoryProcess.class_eval do
  # opublikowanie raportu lub efektu konsultacji powoduje zmiane statusu konsultacji
  CONSULTATION_STATUSES = %w(report effects).freeze

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

  has_many :process_scopes,
           class_name: "Decidim::ParticipatoryProcessesExtended::ProcessScope",
           foreign_key: :decidim_participatory_process_id,
           dependent: :destroy,
           inverse_of: :participatory_process

  # scopes sa nadpisywane, wiec :selected_scopes to wybrane dzielnice dla procesu
  has_many :selected_scopes,
           through: :process_scopes,
           class_name: "Decidim::Scope",
           source: :scope

  has_many :email_follows,
           as: :followable,
           foreign_key: "decidim_followable_id",
           foreign_type: "decidim_followable_type",
           class_name: "Decidim::CoreExtended::EmailFollow",
           dependent: :destroy

  has_many_attached :report_files

  has_many :participatory_process_report_files,
           dependent: :destroy,
           class_name: "Decidim::ParticipatoryProcessesExtended::ParticipatoryProcessReportFile",
           foreign_key: :decidim_participatory_process_id

  has_many :results,
           dependent: :destroy,
           class_name: "Decidim::ParticipatoryProcessesExtended::Result",
           foreign_key: :decidim_participatory_space_id

  geocoded_by :address

  validates :consultation_status, inclusion: { in: CONSULTATION_STATUSES }, if: proc { |attr| attr[:consultation_status].present? }

  scope :sorted_by_name, -> { order(name: :asc) }
  scope :active, -> { where(arel_table[:start_date].lteq(Date.current).and(arel_table[:end_date].gteq(Date.current))) }
  scope :latest_first, -> { order(created_at: :desc) }
  scope :on_main_page, -> { where(show_on_main_page: true) }
  scope :not_on_main_page, -> { where(show_on_main_page: false) }
  scope :order_for_main_page, -> { order(:main_page_weight) }

  # Public: method that returns year of published process start for the search engine.
  # Years are user
  #
  # returns: Integer
  def self.years
    published.where.not(start_date: nil).order(start_date: :desc).map { |pp| pp.start_date&.year }.uniq
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

  scope :with_any_recipients, lambda { |*recipients_ids|
    recipients_ids = recipients_ids.compact_blank
    return self if recipients_ids.none? || recipients_ids.count >= 2

    return where(recipients: %w(ngo mix)) if recipients_ids.include?("ngo")
    where(recipients: %w(citizens mix)) if recipients_ids.include?("citizens")
  }

  # Redefine the with_any_scope method for using with additional scope list table
  scope :with_any_scope, lambda { |*scope_ids|
    clean_scope_ids = scope_ids.flatten
    return self if clean_scope_ids.include?("all")

    joins(:process_scopes).where(process_scopes:{decidim_scope_id: clean_scope_ids.uniq.compact_blank})
  }

  scope :with_any_tag, lambda { |*tags|
    tags = tags.compact_blank
    return self unless tags.any?
    return self if tags.include?("all")

    joins(:process_tags).where("decidim_participatory_processes_extended_process_tags.decidim_admin_extended_tag_id": tags).distinct
  }

  scope :with_any_department, lambda { |*departments_ids|
    departments_ids = departments_ids.compact_blank
    return self unless departments_ids.any?
    return self if departments_ids.include?("all")

    includes(:department).where(decidim_department_id: departments_ids)
  }

  scope :with_any_year, lambda { |*years|
    years = years.compact_blank
    return self unless years.any?

    where("cast(decidim_participatory_processes.start_date AS varchar) ~ :text", text: years.join("|"))
  }
  scope :with_any_date, lambda { |*dates|
    processed_date = dates.reject { |c| c.blank? || c == "report" || c == "effects" }
    processed_status = dates.reject { |c| c.blank? || c == "active" || c == "past" }

    date_query = if processed_date.size == 1
                   case processed_date[0]
                   when "active"
                     active
                   when "past"
                     past
                   else
                     self
                   end
                 else
                   self
                 end

    status_query = if processed_status.empty?
                     date_query
                   else
                     date_query.where("decidim_participatory_processes.consultation_status": processed_status)
                   end
    status_query
  }

  def self.ransackable_scopes(_auth_object = nil)
    [:with_any_date, :with_any_recipients, :with_any_department, :with_any_year, :with_any_scope, :with_any_tag]
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

  def find_possible_followers
    (followers.not_blocked.confirmed.where(email_on_notification: true).to_a) + email_follows.to_a
  end

  # users to notify when process is publish only, filter based on interest
  # return an Array
  def find_published_process_followers
    ids = []

    ids.concat Decidim::User.where(follow_ngo: true).pluck(:id) if recipients.in?(%w(ngo mix))

    ids.concat(
      Decidim::User.where(notifications_from_neighbourhood: true)
                   .where("extended_data->'interested_scopes' @> :scope_id", scope_id: selected_scope_ids.to_s)
                   .pluck(:id)
    )

    ids.concat(
      Decidim::User.where(notifications_from_neighbourhood: true)
                   .where("extended_data->'interested_tags' @> :tag_id", tag_id: tag_ids.to_s)
                   .pluck(:id)
    )

    Decidim::User.not_blocked.confirmed.where(id: ids.uniq).to_a
  end

  def not_for_citizens?
    recipients.present? && recipients != "citizens"
  end
end
