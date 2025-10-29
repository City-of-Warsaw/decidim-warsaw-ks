# frozen_string_literal: true

module Decidim
  module AdminExtended
    # Statistic are used for customizing statistics appeaerance on main site.
    # Users with permissions for updating organization are also allowed to give custom names
    # to the statistics (currently names are not translatable), weight that orders them
    # as well as visibility to hide the stats that are not relevant at some point
    class Statistic < ApplicationRecord
      validates :name, presence: true
      validates :sys_name, uniqueness: true, allow_blank: true

      scope :visible, -> { where(visibility: true) }
      scope :highlited, -> { where(weight: 0) }
      scope :not_highlited, -> { where.not(weight: 0) }
      # get collection where are:
      # - custom ones - created via from
      # - hidden stats specified by Client's request
      scope :excluding_hidden_stats, -> {
        where("sys_name IS NULL OR sys_name NOT IN (?)", hidden_stats)
      }

      default_scope { order(weight: :asc, created_at: :asc) }

      # Public class method updating count values for all elements
      #
      # returns noting
      def self.update_counts
        all.each do |s|
          s.update_column("count", s.count_published)
        end
      end

      # Public method for sum additional number
      # and counted automatically statistics
      def sum_of_count_and_additional_number
        count + additional_statistic_number
      end

      # Public method mapping all available stats: registered + custom
      #
      # Registered stats:
      # - :users_count
      # - :processes_count
      # - :assemblies_count
      # - :comments_count
      # - :followers_count
      # - :participants_count
      def self.manageable_stats
        registered = Decidim.stats.stats.map { |s| s[:name].to_s }
        custom = %w(
          this_year_processes_count
          this_year_meetings_count
          meetings_count
          this_year_meetings_duration
          this_year_remarks_count
          this_year_comments_count
        )
        registered + custom
      end

      # Presenter class for AdminLogs
      def self.log_presenter_class_for(_log)
        Decidim::AdminExtended::AdminLog::StatisticPresenter
      end

      # Counts statistics based on the sys_name attribute.
      #
      # If no year is provided, it returns the count for all time (index view).
      # If a year is provided, it returns the count for that year (archive view).
      #
      # @param year [Integer, nil] The year to filter by (optional).
      # @return [Integer] The count of published records.
      def count_published(year: nil)
        start_at = year ? Date.new(year, 1, 1) : organization.created_at.to_date
        end_at = year ? Date.new(year, 12, 31) : Date.current
        this_year_start = Date.current.beginning_of_year

        case sys_name
        when "users_count"
          users_count(start_at, end_at)
        when "processes_count"
          processes_count(start_at, end_at)
        when "this_year_processes_count"
          # warning!
          # this is this_year stat
          # it behaves differently depending from index / archive view
          this_year_processes_count(year, start_at, this_year_start, end_at)
        when "assemblies_count"
          assemblies_count(start_at, end_at)
        when "comments_count"
          comments_count(start_at, end_at)
        when "this_year_comments_count"
          # warning!
          # this is this_year stat
          # it behaves differently depending from index / archive view
          this_year_comments_count(year, start_at, this_year_start, end_at)
        when "followers_count"
          followers_count(start_at,end_at)
        when "participants_count"
          0
        when "meetings_count"
          meetings_count(start_at, end_at)
        when "this_year_meetings_count"
          # warning!
          # this is this_year stat
          # it behaves differently depending from index / archive view
          this_year_meetings_count(year, start_at, this_year_start, end_at)
        when "this_year_remarks_count"
          # warning!
          # this is this_year stat
          # it behaves differently depending from index / archive view
          this_year_remarks_count(year, start_at, this_year_start, end_at)
        when "this_year_meetings_duration"
          # the condition is for archive view
          # without it there is no data for previous years
          this_year_meetings_duration(year, start_at, this_year_start, end_at)
        else
          # Default return value
          0
        end
      end

      # Specified by Client's request
      def self.hidden_stats
        %w(
          assemblies_count
          comments_count
          followers_count
          participants_count
          this_year_comments_count
        )
      end

      def organization
        Decidim::Organization.first
      end

      # Public method
      #
      # Used for Archive
      #
      # Returns an Array with years from the organization creation year up to the previous year
      def past_years
        (organization.created_at.year..Date.current.year - 1).to_a
      end

      private

      # Private method
      # used for count_published
      def users_count(start_at, end_at)
        Decidim::StatsUsersCount.for(organization, start_at, end_at)
      end

      # Private method
      # used for count_published
      def processes_count(start_at, end_at)
        Decidim::ParticipatoryProcess.where(organization: organization)
                                     .public_spaces
                                     .where(start_date: start_at..end_at)
                                     .count
      end

      # Private method
      # used for count_published
      def this_year_processes_count(year, start_at, this_year_start, end_at)
        Decidim::ParticipatoryProcess.where(organization: organization)
                                     .public_spaces
                                     .where(start_date: (year ? start_at : this_year_start)..end_at)
                                     .count
      end

      # Private method
      # used for count_published
      def assemblies_count(start_at, end_at)
        Decidim::Assembly.where(organization: organization).public_spaces.where(created_at: start_at..end_at).count
      end

      # Private method
      # used for count_published
      def comments_count(start_at, end_at)
        Decidim::Comments::Comment.not_hidden.where(created_at: start_at..end_at).count
      end

      # Private method
      # used for count_published
      def this_year_comments_count(year, start_at, this_year_start, end_at)
        Decidim::Comments::Comment.not_hidden.where(created_at: (year ? start_at : this_year_start)..end_at).count
      end

      # Private method
      # used for count_published
      def followers_count(start_at, end_at)
        Decidim::Follow.where(created_at: start_at..end_at).count
      end

      # Private method
      # used for count_published
      def meetings_count(start_at, end_at)
        Decidim::Meetings::Meeting.visible.where(start_time: start_at..end_at).count
      end

      # Private method
      # used for count_published
      def this_year_meetings_count(year, start_at, this_year_start, end_at)
        Decidim::Meetings::Meeting.visible.where(start_time: (year ? start_at : this_year_start)..end_at).count
      end

      # Private method
      # used for this_year_remarks_count
      def not_hidden_remarks_count(year, start_at, this_year_start, end_at)
        Decidim::Remarks::Remark.not_hidden.where(created_at: (year ? start_at : this_year_start)..end_at).count
      end

      # Private method
      # used for this_year_remarks_count
      def not_hidden_remarks_on_map_count(year, start_at, this_year_start, end_at)
        Decidim::ConsultationMap::Remark.not_hidden.where(created_at: (year ? start_at : this_year_start)..end_at).count
      end

      # Private method
      # return number of questionneres field by users
      # used for this_year_remarks_count
      def published_surveys_count(year, start_at, this_year_start, end_at)
        # Decidim::Component.where(manifest_name: "surveys")
        #                   .where(published_at: (year ? start_at : this_year_start)..end_at)
        #                   .count
        Decidim::Forms::Answer.where(created_at: (year ? start_at : this_year_start)..end_at).group(:session_token).count.keys.size
      end

      # Private method
      # used for this_year_remarks_count
      def custom_proposal_not_hidden_comments_count(year, start_at, this_year_start, end_at)
        Decidim::Comments::Comment.where(
          created_at: (year ? start_at : this_year_start)..end_at,
          decidim_root_commentable_type: "Decidim::CustomProposals::CustomProposal"
        )
                                  .not_hidden
                                  .count
      end

      # Private method
      # used for count_published
      # Stores combined numerical value relating to the count:
      # - remarks - uwagi
      # - remarks_on_map - uwagi na mapie
      # - surveys - ankiety
      # - custom_proposal_comments - komentarze należące do fragmentu dokumentu
      def this_year_remarks_count(year, start_at, this_year_start, end_at)
        remarks = not_hidden_remarks_count(year, start_at, this_year_start, end_at)
        remarks_on_map = not_hidden_remarks_on_map_count(year, start_at, this_year_start, end_at)
        surveys = published_surveys_count(year, start_at, this_year_start, end_at)
        custom_proposal_comments = custom_proposal_not_hidden_comments_count(year, start_at, this_year_start, end_at)

        remarks + remarks_on_map + surveys + custom_proposal_comments
      end

      # Private method
      # used for count_published
      def this_year_meetings_duration(year, start_at, this_year_start, end_at)
        total_duration_seconds = Decidim::Meetings::Meeting.visible
                                                           .where(start_time: (year ? start_at : this_year_start)..end_at)
                                                           .sum("EXTRACT(EPOCH FROM (end_time - start_time))")
        (total_duration_seconds / 1800.0).round * 0.5
      end
    end
  end
end
