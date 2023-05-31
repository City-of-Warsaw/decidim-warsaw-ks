# frozen_string_literal: true

Decidim::Meetings::ApplicationHelper.class_eval do
  def filter_type_values
    mapped = Decidim::Meetings::Meeting::TYPE_OF_MEETING.map do |type|
      [t("decidim.meetings.meetings.filters.type_values.#{type}"), type]
    end
    mapped
  end

  def filter_date_values
    [
      # [t("decidim.meetings.meetings.filters.date_values.all"), ''],
      [t("decidim.meetings.meetings.filters.date_values.upcoming"), 'upcoming'],
      [t("decidim.meetings.meetings.filters.date_values.past"), 'past'],
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
    html = ""
    if agenda_item_id == agenda_items_times[index][:agenda_item_id]
      html += "#{agenda_items_times[index][:start_time].strftime("%H:%M")} - #{agenda_items_times[index][:end_time].strftime("%H:%M")}"
    end
    html.html_safe
  end
end