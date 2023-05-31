# frozen_string_literal: true

# Class Decorator - Extending Decidim::Meetings::MeetingMCell
#
# Decorator implements additional functionalities to the Cell
# and changes existing methods.
Decidim::Meetings::MeetingMCell.class_eval do

  def title
    truncate(present(model).title, length: 55)
  end

  def description
    attribute = model.try(:short_description) || model.try(:body) || model.description
    text = translated_attribute(attribute)

    decidim_sanitize(html_truncate(text, length: 150))
  end

  def meeting_date_details
    "<strong>#{l(model.start_time, format: "%d.%m.%Y")}</strong>, #{l(model.start_time, format: "%A")} #{model.start_time.strftime("%H:%M")}-#{model.end_time.strftime("%H:%M")}"
  end

  def location
    decidim_sanitize(translated_attribute(model.location), strip_tags: true)
  end

  def location_details
    if model.online_meeting?
      link_to(("Link do spotkania<span class='show-for-sr'> " + translated_attribute(model.title) + "</span>").html_safe, model.online_meeting_url, target: "_blank")
    elsif model.type_of_meeting == "hybrid"
      model.address_simple + link_to(("Link do spotkania<span class='show-for-sr'> " + translated_attribute(model.title) + "</span>").html_safe, model.online_meeting_url, target: "_blank", style: "display:block;")
    else
      model.address_simple
    end
  end

  def meeting_type
    t(model.type_of_meeting, scope: 'decidim.meetings.type_of_meeting')
  end
end
