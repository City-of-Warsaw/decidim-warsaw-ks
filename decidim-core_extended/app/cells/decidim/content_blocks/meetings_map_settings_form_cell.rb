# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class MeetingsMapSettingsFormCell < Decidim::ViewModel
      alias form model

      def content_block
        options[:content_block]
      end

      def show
        render :show
      end

      def meetings_from_published_spaces
        @meetings_from_published_spaces ||= upcoming_published_meetings.map { |meeting| [meeting.title["pl"], meeting.id] }
      end

      def published_meeting_components
        @published_meeting_components ||= current_organization.published_components.where(manifest_name: 'meetings')
      end

      def upcoming_published_meetings
        @upcoming_published_meetings ||= Decidim::Meetings::Meeting
                                         .includes(component: :participatory_space)
                                         .where(component: published_meeting_components)
                                         .published
                                         .current_and_upcoming
      end

    end
  end
end
