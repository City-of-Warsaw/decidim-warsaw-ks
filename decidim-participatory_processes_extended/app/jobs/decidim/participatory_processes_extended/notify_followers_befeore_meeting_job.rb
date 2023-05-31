# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    # Notify followers about future meeting's start, 2 days before
    class NotifyFollowersBefeoreMeetingJob < ApplicationJob
      include Decidim::EmailChecker

      DAYS_BEFORE_MEETING_START = 2.days

      queue_as :events

      # days_before_finish - notify process only on X days before process finished
      def perform(days_before_start = DAYS_BEFORE_MEETING_START, additional_data = {})
        meetings = Decidim::Meetings::Meeting.where("start_time::date = ?", Date.current + days_before_start)
        meetings.each do |meeting|
          notify_meeting_in_two_days(meeting)
        end
      end

      private

      def notify_meeting_in_two_days(meeting)
        # TODO: uzupelnic powiadomienia
        # Decidim::NotificationGeneratorJob.perform_later(
        #   "decidim.events.participatory_process.two_days_till_meeting",
        #   "Decidim::ParticipatoryProcessesExtended::TwoDaysTillMeetingEvent",
        #   participatory_process,
        #   participatory_process.find_possible_followers.uniq.compact, # followers
        #   [], # affected_users
        #   {}
        # )

        process = meeting.participatory_space
        Decidim::CoreExtended::TemplatedMailerJob.perform_now('meeting_in_two_days',
                                                                {
                                                                  resource: meeting,
                                                                  consultation: process,
                                                                  meeting: meeting
                                                                })
      end

    end
  end
end