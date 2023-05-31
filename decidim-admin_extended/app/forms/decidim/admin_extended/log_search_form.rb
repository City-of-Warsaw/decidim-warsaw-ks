# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A form object to search action logs for admin
    class LogSearchForm < Form
      attribute :participatory_space_id, Integer
      attribute :user_id, Integer
      attribute :start_date, Decidim::Attributes::LocalizedDate
      attribute :end_date, Decidim::Attributes::LocalizedDate
      attribute :sort_by, String

      mimic :log_search

      def find_logs
        logs = Decidim::ActionLog
                 .where(organization: current_organization)
                 .includes(:participatory_space, :user, :resource, :component, :version)
                 .for_admin
        logs = logs.where(participatory_space_id: participatory_space_id) if participatory_space_id.present?
        logs = logs.where(decidim_user_id: user_id)      if user_id.present?
        logs = logs.where("DATE(created_at) >= ?", start_date) if start_date.present?
        logs = logs.where("DATE(created_at) <= ?", end_date)   if end_date.present?
        logs = if sort_by.in?(%w'created_at_asc created_at_desc')
                 sort_by == 'created_at_asc' ? logs.order(created_at: :asc) : logs.order(created_at: :desc)
               else
                 logs.order(created_at: :desc)
               end
        logs
      end

      def users_select
        # current_organization.admins.or(current_organization.users_with_any_role).map do |user|
        Decidim::User.with_ad_role.map do |user|
          [
            user.name,
            user.id
          ]
        end
      end

      def processes_select
        # Decidim::ParticipatoryProcessesWithUserRole.for(current_user).map do |process|
        Decidim::ParticipatoryProcess.where(organization: current_organization).map do |process|
          [
            process.title["pl"],
            process.id
          ]
        end
      end

      def sort_by_select
        [
          ['Od najstarszych', 'created_at_asc'],
          ['Od najnowszych', 'created_at_desc']
        ]
      end

    end
  end
end
