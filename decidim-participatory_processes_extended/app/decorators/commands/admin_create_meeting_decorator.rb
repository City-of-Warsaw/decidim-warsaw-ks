# frozen_string_literal: true

# Class Decorator - Extending Decidim::Meetings::Admin::CreateMeeting
#
# Decorator implements additional functionalities to the Command
# and changes existing methods.
Decidim::Meetings::Admin::CreateMeeting.class_eval do

  private

  def create_meeting!
    parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
    parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: form.current_organization).rewrite
    params = {
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
      author: form.current_organization,
      registration_terms: form.current_component.settings.default_registration_terms,
      component: form.current_component,
      questionnaire: Decidim::Forms::Questionnaire.new,
      # custom
      address: location_param_parsed('display_name'),
      latitude: location_param_parsed('lat'),
      longitude: location_param_parsed('lng'),
      locations: form.locations_data,
      gallery_id: form.gallery_id
    }

    @meeting = Decidim.traceability.create!(
      Decidim::Meetings::Meeting,
      form.current_user,
      params,
      visibility: "all"
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
  def send_notification
    Decidim::NotificationGenerator.new(
      "decidim.events.meetings.meeting_created",
      Decidim::Meetings::CreateMeetingEvent,
      meeting,
      meeting.participatory_space.followers, # followers
      Decidim::User.none, # affected_users
      {}
    ).generate
    # Custom email
    Decidim::CoreExtended::TemplatedMailerJob.perform_later('new_meeting',
                                                            {
                                                              resource: meeting,
                                                              consultation: meeting.participatory_space
                                                            })
  end
end