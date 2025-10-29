# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class MeetingsMapCell < Decidim::ViewModel
      include Decidim::CardHelper

      def show
        render :show if selected_meetings.any?
      end

      private

      def selected_meetings
        @selected_meetings ||= if model.settings.meetings_selection == "five_meetings"
                                 current_and_upcoming_published_meetings.where(id: selected_five_meetings_ids)
                               else
                                 current_and_upcoming_published_meetings
                               end.sorted_by_start_time
      end

      def selected_five_meetings_ids
        [

          model.settings.first_meeting,
          model.settings.second_meeting,
          model.settings.third_meeting,
          model.settings.fourth_meeting,
          model.settings.fifth_meeting
        ]
      end

      def published_meeting_components
        @published_meeting_components ||= current_organization.published_components.where(manifest_name: "meetings")
      end

      def current_and_upcoming_published_meetings
        @current_and_upcoming_published_meetings ||= Decidim::Meetings::Meeting.includes(component: :participatory_space)
                                                                               .where(component: published_meeting_components).published.current_and_upcoming
      end
    end
  end
end
