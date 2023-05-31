# frozen_string_literal: true

# Class Decorator - Extending Decidim::Meetings::ContentBlocks::UpcomingEventsCell
#
# Decorator implements additional functionalities to the Cell
# and changes existing methods.
Decidim::Meetings::ContentBlocks::UpcomingEventsCell.class_eval do
  def show
    return if upcoming_events.blank?

    render :show_new
  end

  def show_content_block?
    upcoming_events.any?
  end

  def upcoming_events
    @upcoming_events ||= Decidim::Meetings::Meeting
                           .includes(component: :participatory_space)
                           .where(component: meeting_components)
                           .visible_meeting_for(current_user)
                           .where("end_time >= ?", Time.current)
                           # .order(start_time: :asc)

  end
end