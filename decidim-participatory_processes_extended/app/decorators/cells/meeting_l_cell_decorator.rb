# frozen_string_literal: true

Decidim::Meetings::MeetingLCell.class_eval do
  # overwritten method
  # use our view
  def show
    render :show_new
  end

  def past_meeting_class
    "meeting--past"
  end
end
