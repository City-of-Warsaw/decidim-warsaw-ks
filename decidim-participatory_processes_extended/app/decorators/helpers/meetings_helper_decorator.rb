# frozen_string_literal: true

Decidim::Meetings::ApplicationHelper.class_eval do
  # def filter_type_values
  #   mapped = Decidim::Meetings::Meeting::TYPE_OF_MEETING.map do |type|
  #     [t("decidim.meetings.meetings.filters.type_values.#{type}"), type]
  #   end
  #   mapped
  # end

  def filter_date_values
    [
      ['', t("decidim.meetings.meetings.filters.date_values.all")],
      ['upcoming', t('decidim.meetings.meetings.filters.date_values.upcoming') ],
      ['past', t('decidim.meetings.meetings.filters.date_values.past'), ]
    ]
  end

  # Public: This method is used to build the html for show start
  # and end time of each agenda item
  #
  # agenda_item_id - an id of agenda item
  # agenda_items_times - is a hash with the two times
  #
  # Returns an HMTL.
  def display_duration_agenda_items(agenda_item_id, index, agenda_items_times)
    html = ''
    if agenda_item_id == agenda_items_times[index][:agenda_item_id]
      html += "#{agenda_items_times[index][:start_time].strftime('%H:%M')} - #{agenda_items_times[index][:end_time].strftime('%H:%M')}"
    end
    html.html_safe
  end

  # Public: This methods is used to build the link compatibile with google / outlook / office365
  #
  # meeting - meeting object
  #
  # Returns an prepared URL.
  def calendar_google_link
    link_params = {
      action: 'TEMPLATE',
      text: meeting.title['pl'],
      details: sanitize(meeting.description['pl']),
      location: (meeting.address.present? ? meeting.address : meeting.location['pl']),
      dates: meeting.start_time.strftime('%Y%m%dT%H%M%S') + '/' + meeting.end_time.strftime('%Y%m%dT%H%M%S')
    }.to_param
    'https://www.google.com/calendar/render?' + link_params
  end

  def calendar_apple
    'data:text/calendar;%0Acharset=utf8,%0A%0ABEGIN:VCALENDAR%0A%0AVERSION:2.0%0A%0ABEGIN:VEVENT%0A%0ADTSTART:' +
      meeting.start_time.strftime('%Y%m%dT%H%MZ') +
      '%0A%0ADTEND:' + meeting.end_time.strftime('%Y%m%dT%H%MZ') +
      '%0A%0ASUMMARY:' + meeting.title['pl'] +
      '%0A%0ADESCRIPTION:' + sanitize(meeting.description['pl']) +
      '%0A%0ALOCATION: ' +  (meeting.address.present? ? meeting.address : meeting.location['pl']) +
      '%0A%0AEND:VEVENT%0A%0AEND:VCALENDAR%0A%0A'
  end

  def calendar_outlook_link
    link_params = {
      body: sanitize(meeting.description['pl']),
      location:  (meeting.address.present? ? meeting.address : meeting.location['pl']),
      subject: meeting.title['pl'],
      startdt: meeting.start_time.strftime('%FT%T%:z'),
      enddt: meeting.end_time.strftime('%FT%T%:z'),
      path: '/calendar/action/compose',
      rru: 'addevent'
    }.to_param
    'https://outlook.live.com/calendar/0/deeplink/compose?' + link_params
  end

  def calendar_o365_link
    link_params = {
      body: sanitize(meeting.description['pl']),
      location:  (meeting.address.present? ? meeting.address : meeting.location['pl']),
      subject: meeting.title['pl'],
      startdt: meeting.start_time.strftime('%FT%T%:z'),
      enddt: meeting.end_time.strftime('%FT%T%:z'),
      path: '/calendar/action/compose',
      rru: 'addevent'
    }.to_param
    'https://outlook.office.com/calendar/0/deeplink/compose?' + link_params
  end
end
