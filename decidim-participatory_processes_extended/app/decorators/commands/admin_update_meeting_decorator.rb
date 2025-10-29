# frozen_string_literal: true

# Class Decorator - Extending Decidim::Meetings::Admin::UpdateMeeting
#
# Decorator implements additional functionalities to the Command
# and changes existing methods.
Decidim::Meetings::Admin::UpdateMeeting.class_eval do
  include Decidim::Repository::Admin::GalleriesHelper

  # overwrite method
  # rebuild the method
  # add create gallery
  # remove schedule upcoming meeting notification
  # add our notification system
  def call
    return broadcast(:invalid) if form.invalid?

    transaction do
      update_meeting!
      send_notification if should_notify_followers? && meeting.component.published?
      update_services!
    end
    add_gallery(@meeting)

    broadcast(:ok, meeting)
  end

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
      title_description: form.title_description,
      title_services: form.title_services,
      end_time: form.end_time,
      start_time: form.start_time,
      online_meeting_url: form.online_meeting_url,
      registration_type: form.registration_type,
      registration_url: form.registration_url,
      registrations_enabled: form.registrations_enabled,
      type_of_meeting: form.clean_type_of_meeting,
      # address: form.address,
      # latitude: form.latitude,
      # longitude: form.longitude,
      location: form.location,
      location_hints: form.location_hints,
      private_meeting: form.private_meeting,
      transparent: form.transparent,
      iframe_embed_type: form.iframe_embed_type,
      comments_enabled: form.comments_enabled,
      comments_start_time: form.comments_start_time,
      comments_end_time: form.comments_end_time,
      iframe_access_level: form.iframe_access_level,
      # custom overwritten
      address: location_param_parsed("display_name"),
      latitude: location_param_parsed("lat"),
      longitude: location_param_parsed("lng"),
      locations: form.locations_data,
      gallery_id: form.gallery_id
    )
  end

  def location_param_parsed(param)
    form.locations_data.any? ? form.parse_locations[param] : nil
  end

  # overwritten method
  # use our notification system
  #
  # NOTE! Method is fired:
  # - after method should_notify_followers? returns true
  # - only if it is published
  def send_notification
    Decidim::CoreExtended::TemplatedMailerJob.perform_later("meeting_updated", { resource: meeting })
  end
end
