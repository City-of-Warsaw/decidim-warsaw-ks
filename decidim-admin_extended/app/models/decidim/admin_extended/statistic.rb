# frozen_string_literal: true

module Decidim
  module AdminExtended
    # Statistic are used for customizing statistics appeaerance on main site.
    # Users with permissions for updating organization are also allowed to give custom names
    # to the statistics (currently names are not translatable), weight that orders them
    # as well as visibility to hide the stats that are not relevant at some point:
    # - for example all the stats with sys_name starting with "this_year" that count
    # elements for current year can be irrelevant right at the beginning of the year
    #
    # In the future, Statistic can be customized more by giving administrators possibility to add statistics data
    # from outside the platform.
    class Statistic < ApplicationRecord
      validates :name, presence: true
      validates :sys_name, uniqueness: true

      scope :visible, -> { where(visibility: true) }
      scope :highlited, -> { where(weight: 0) }
      scope :not_highlited, -> { where.not(weight: 0) }

      default_scope { order(weight: :asc, created_at: :asc) }

      # Public class method updating count values for all elements
      #
      # returns noting
      def self.update_counts
        all.each do |s|
          s.update_column('count', s.count_published)
        end
      end

      # Public method mapping all available stats: registered + custom
      #
      # Registered stats:
      # [:users_count, :processes_count, :assemblies_count, :comments_count, :followers_count, :participants_count]
      def self.manageable_stats
        registered = Decidim.stats.stats.map { |s| s[:name].to_s }
        registered + %w[this_year_processes_count this_year_meetings_count meetings_count
                        this_year_remarks_count this_year_comments_count]
      end

      # Public method counting elements for statistics, based on a sys_name attribute
      #
      # returns: Integer
      def count_published
        organization = Decidim::Organization.first
        start_at = (Date.current - 10.years)
        # end_at = Date.current
        this_year_start = Date.current.beginning_of_year

        case sys_name
        when 'users_count'
          Decidim::StatsUsersCount.for(organization, start_at, Date.current)
        when 'processes_count'
          Decidim::ParticipatoryProcess.where(organization: organization).public_spaces.count
        when 'this_year_processes_count'
          Decidim::ParticipatoryProcess
            .where(organization: organization)
            .public_spaces
            .where("start_date >= ?", this_year_start)
            .count
        when 'assemblies_count'
          Decidim::Assembly.where(organization: organization).public_spaces.count
        when 'comments_count'
          Decidim::Comments::Comment.all.not_hidden.count
        when 'this_year_comments_count'
          Decidim::Comments::Comment.all.not_hidden.where("decidim_comments_comments.created_at >= ?", this_year_start).count
        when 'followers_count'
          Decidim::Follow.count
        when 'participants_count'
          # Decidim::User.all.count
          0
        when 'users_count'
          Decidim::User.all.count
        when 'meetings_count'
          Decidim::Meetings::Meeting.visible.count
        when 'this_year_meetings_count'
          Decidim::Meetings::Meeting
            .visible
            .where("start_time >= ?", this_year_start)
            .count
        when 'this_year_remarks_count'
          Decidim::Remarks::Remark.all.not_hidden.where("decidim_remarks_remarks.created_at >= ?", this_year_start).count
        else
          0
        end
      end
    end
  end
end
