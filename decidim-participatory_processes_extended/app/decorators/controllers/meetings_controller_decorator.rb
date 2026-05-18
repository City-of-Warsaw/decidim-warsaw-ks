# frozen_string_literal: true

Decidim::Meetings::MeetingsController.class_eval do
  include Decidim::CoreExtended::CommentTokenCookie

  # overwritten method action
  # remove permission can visit meeting
  # add calendar
  def show
    raise ActionController::RoutingError, "Not Found" unless meeting

    respond_to do |format|
      format.html
      format.ics do
        calendar = Icalendar::Calendar.new
        converter = Decidim::Meetings::Calendar::MeetingToEvent.new(meeting)
        calendar.add_event(converter.event)

        send_data calendar.to_ical,
                  type: "text/calendar",
                  disposition: "attachment",
                  filename: "#{meeting.title["pl"]}.ics"
      end
    end
  end

  private

  # overwritten method
  # it comes from decidim-meetings-0.29.3/app/controllers/concerns/decidim/meetings/component_filterable.rb
  # replace upcoming with blank, meaning -> all
  def default_filter_params
    {
      search_text_cont: "",
      with_any_date: "",
      activity: "all",
      with_availability: "",
      with_any_scope: nil,
      with_any_category: nil,
      with_any_state: nil,
      with_any_origin: nil,
      with_any_type: nil
    }
  end
end
