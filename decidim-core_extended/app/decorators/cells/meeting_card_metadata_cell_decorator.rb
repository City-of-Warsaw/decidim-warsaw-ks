# frozen_string_literal: true

Decidim::Meetings::MeetingCardMetadataCell.class_eval do
  private

  # overwritten method
  # add our custom method: start_date_day
  def meeting_items
    [start_date_day] + [start_date_item, type, comments_count_item, category_item, withdrawn_item]
  end

  # overwritten method
  # use our custom method to add proper text depending from meeting type
  def type
    {
      text: address_for_type,
      icon: resource_type_icon_key(type_of_meeting)
    }
  end

  def address_for_type
    if model.type_of_meeting == "in_person" || model.type_of_meeting == "hybrid"
      model.address_simple
    else
      t(type_of_meeting, scope: "decidim.meetings.meetings.filters.type_values")
    end
  end

  # overwritten method
  # remove %p %Z
  def start_date_item
    return if dates_blank?

    {
      text: I18n.l(start_date, format: "%H:%M"),
      icon: "time-line"
    }
  end

  def start_date_day
    return if start_date.blank?

    {
      text: I18n.l(start_date, format: "%A").camelize,
      icon: nil
    }
  end
end
