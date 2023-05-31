# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    class NotifyFollowersBefeoreProcessFinishJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      # days_before_finish - notify process only on X days before process finished
      def perform(days_before_finish = 2.days, additional_data = {})
        processes = Decidim::ParticipatoryProcess
                       .published
                       .active
                       .where(
                         Decidim::ParticipatoryProcess.arel_table[:end_date].eq(Date.current + days_before_finish)
                       )
        processes.each do |participatory_process|
          notify_process_finish_in_two_days(participatory_process)
        end
      end

      private

      def notify_process_finish_in_two_days(participatory_process)
        Decidim::NotificationGeneratorJob.perform_later(
          "decidim.events.participatory_process.two_days_till_consultations_end",
          "Decidim::ParticipatoryProcessesExtended::TwoDaysTillParticipatoryProcessFinishEvent",
          participatory_process,
          participatory_process.find_possible_followers.uniq.compact, # followers
          [], # affected_users
          {}
        )

        Decidim::CoreExtended::TemplatedMailerJob.perform_now('two_days_till_consultations_end',
                                                                {
                                                                  resource: participatory_process,
                                                                  consultation: participatory_process
                                                                })
      end
    end
  end
end