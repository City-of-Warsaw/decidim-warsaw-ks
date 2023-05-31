# frozen_string_literal: true

# this module overwrites the latitude and longitude of meetings
# to fetch data from participatory space or scope if there was no addres
Decidim::Meetings::MapHelper.module_eval do

  # Public: Overwritten method
  #
  # Method returns Hash with changed meeting data.
  # Changed elements:
  # - latitude - returns meeting.lat
  # - longitude - returns meeting.lng
  # - address - returns meeting.found_address
  # - icon - returns one of two icons: for online and in_person meetings
  # Added elements:
  # - weekDay - translated name of the week
  # - startDate - meeting start date in format: "%d.%m.%Y"
  # - locationDetails - returns either address (for in_person) or link to online meeting
  # - meetingTypeTr - translated meeting type
  # - meetingType - meeting type (for if clauses)
  # Removed elements:
  # - startTimeDay
  # - startTimeMonth
  # - startTimeYear
  # - locationHints
  def meetings_data_for_map(meetings)
    geocoded_meetings = meetings.select(&:geocoded_and_valid?)
    geocoded_meetings.map do |meeting|
      title = translated_attribute(meeting.title)
      {
        latitude: meeting.lat,
        longitude: meeting.lng,
        address: meeting.found_address,
        title: title,
        description: html_truncate(translated_attribute(meeting.description), length: 200),
        scope_name: translated_attribute(meeting.main_scope.name),
        weekDay: l(meeting.start_time, format: "%A"),
        startDate: l(meeting.start_time, format: "%d.%m.%Y"),
        # startTimeDay: l(meeting.start_time, format: "%d"),
        # startTimeMonth: l(meeting.start_time, format: "%B"),
        # startTimeYear: l(meeting.start_time, format: "%Y"),
        startTime: "#{meeting.start_time.strftime("%H:%M")} – #{meeting.end_time.strftime("%H:%M")}",
        icon: if meeting.online_meeting?
                icon = content_tag :span, '', class: 'meeting-icon', role: 'img'
                icon += content_tag :span, '', class: 'meeting-icon-circle', role: 'img'
                icon
              else
                icon('meetings', width: 40, height: 70, remove_icon_class: true)
              end,
        location: translated_attribute(meeting.location),
        locationDetails: if meeting.online_meeting?
                           link_to(("Link do spotkania<span class='show-for-sr'> " + translated_attribute(meeting.title) + "</span>").html_safe, meeting.online_meeting_url, target: "_blank")
                         elsif meeting.type_of_meeting == "hybrid"
                           meeting.address_simple + " / " + link_to(("Link do spotkania<span class='show-for-sr'> " + translated_attribute(meeting.title) + "</span>").html_safe, meeting.online_meeting_url, target: "_blank")
                         else
                           meeting.address_simple
                         end,
        # locationHints: decidim_html_escape(translated_attribute(meeting.location_hints)),
        meetingTypeTr: t(meeting.type_of_meeting, scope: 'decidim.meetings.type_of_meeting'),
        meetingType: t(meeting.type_of_meeting, scope: 'decidim.meetings.type_of_meeting'),
        link: resource_locator(meeting).path
      }
    end
  end
end