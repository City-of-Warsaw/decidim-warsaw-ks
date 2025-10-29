# frozen_string_literal: true

Decidim::Component.class_eval do
  # check if user actions (new comment, new remark, new questions) are active in this component
  def users_action_disallowed?
    if manifest.name == :surveys
      !users_action_in_survey_allowed?
    else
      users_action_end_date&.past?
    end
  end

  # only for :survey component, it has its own ends_at date, so it dont use :users_action_end_date
  def users_action_in_survey_allowed?
    ends_at = settings.ends_at
    ends_at.blank? || ends_at.future?
  end

  def with_help_section?
    help_section.visibility && help_section.title.present?
  end

  def help_section
    OpenStruct.new(
      title: settings[:help_section_title],
      subtitle: settings[:help_section_subtitle],
      visibility: settings[:help_section_visibility],
      description: settings[:help_section_description]
    )
  end
end
