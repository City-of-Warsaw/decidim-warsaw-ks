# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    # This job notifies process followers about a meeting, X days before it starts.
    # DAYS_BEFORE_MEETING_START defines how many days in advance the notification is sent.
    class NotifyFollowersBeforeMeetingJob < ApplicationJob
      include Decidim::EmailChecker

      DAYS_BEFORE_MEETING_START = 2.days

      queue_as :events

      def perform(days_before_start = DAYS_BEFORE_MEETING_START)
        meetings = Decidim::Meetings::Meeting.where("start_time::date = ?", Date.current + days_before_start)
        meetings.each do |meeting|
          notify_process_followers_about_meeting(meeting)
        end
      end

      private

      # na życzenie klienta
      # followersi procesu do którego to spotkanie należy
      # resource musi być spotkaniem, ponieważ w mail helperach musi być dostęp do:
      # - resource - spotkania
      # - consultation - konsultacji tego spotkania
      def notify_process_followers_about_meeting(meeting)
        action_name = "meeting_in_two_days"
        resource = meeting
        receivers = meeting.participatory_space.find_possible_followers

        receivers.each do |receiver|
          Rails.logger.debug { "[NotifyFollowersBeforeMeetingJob] Receiver #{receiver.inspect}" }
          Decidim::ParticipatoryProcessesExtended::MeetingMailer.notify(
            action_name, resource, receiver
          ).deliver_later
        end
      end
    end
  end
end
