# frozen_string_literal: true

# Class Decorator - Extending Decidim::Meetings::Admin::UpdateMeeting
#
# Decorator implements additional functionalities to the Command
# and changes existing methods.
Decidim::Meetings::Admin::UpdateMeeting.class_eval do
  private

  def update_meeting!
    parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
    parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: form.current_organization).rewrite

    Decidim.traceability.update!(
      meeting,
      form.current_user,
      scope: form.scope,
      category: form.category,
      title: parsed_title,
      description: parsed_description,
      end_time: form.end_time,
      start_time: form.start_time,
      online_meeting_url: form.online_meeting_url,
      registration_type: form.registration_type,
      registration_url: form.registration_url,
      available_slots: form.available_slots,
      type_of_meeting: form.clean_type_of_meeting,
      # address: form.address,
      # latitude: form.latitude,
      # longitude: form.longitude,
      location: form.location,
      location_hints: form.location_hints,
      private_meeting: form.private_meeting,
      transparent: form.transparent,
      # custom overwritten
      address: location_param_parsed('display_name'),
      latitude: location_param_parsed('lat'),
      longitude: location_param_parsed('lng'),
      locations: form.locations_data,
      gallery_id: form.gallery_id
    )
  end

  def location_param_parsed(param)
    form.locations_data.any? ? form.parse_locations[param] : nil
  end

  # OVERWRITTEN DECIDIM METHOD
  #
  # Method was creating Notification AND email in one method.
  # Notification is being send via Decidim method.
  # Custom email is send instead of default one
  #
  # NOTE! Method is fired after method should_notify_followers? returns true
  def send_notification
    Decidim::NotificationGenerator.new(
      "decidim.events.meetings.meeting_updated",
      Decidim::Meetings::UpdateMeetingEvent,
      meeting,
      meeting.followers, # followers
      Decidim::User.none, # affected_users
      {}
    ).generate
    # Custom email
    Decidim::CoreExtended::TemplatedMailerJob.perform_later('meeting_updated',
                                                          {
                                                            resource: meeting,
                                                            consultation: meeting.participatory_space
                                                          })
  end
end