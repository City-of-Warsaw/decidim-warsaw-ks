# frozen_string_literal: true

Decidim::Meetings::Admin::Permissions.class_eval do
  include Decidim::Admin::PermissionsHelper

  def allowed_meeting_action?
    return unless permission_action.subject == :meeting
    return disallow! if meeting && !meeting.official?

    case permission_action.action
    when :export_registrations, :read_invites
      toggle_allow(meeting.present? && (user.ad_admin? || is_coordinator_in_space?))
    when :close, :copy, :destroy, :update
      toggle_allow(meeting.present? && (user.ad_admin? || is_coordinator_in_space? && !current_participatory_space.published?))
    when :invite_attendee
      toggle_allow(meeting.present? && meeting.registrations_enabled?)
    when :create
      toggle_allow(user.ad_admin? || is_coordinator_in_space? && !current_participatory_space.published?)
    end
  end

end