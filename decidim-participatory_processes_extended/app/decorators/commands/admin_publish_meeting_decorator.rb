# frozen_string_literal: true

Decidim::Meetings::Admin::PublishMeeting.class_eval do
  # overwrite method
  # remove send notification
  # remove schedule upcoming meeting
  # remove transaction
  def call
    return broadcast(:invalid) if meeting.published?

    publish_meeting

    broadcast(:ok, meeting)
  end
end
