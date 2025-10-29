# frozen_string_literal: true

Decidim::Admin::UpdateComponent.class_eval do
  private

  # overwritten method
  # normalize survey ends at
  # add custom attrs
  def update_component
    @previous_settings = @component.attributes["settings"].with_indifferent_access
    @component.name = form.name
    @component.weight = form.weight

    restore_readonly_settings!

    # dla ankiety ustawiamy czas na koniec dnia przed przypisaniem wartości z formularza
    normalize_survey_ends_at!

    @component.settings = form.settings
    @component.default_step_settings = form.default_step_settings
    @component.step_settings = form.step_settings

    # custom attrs:
    @component.custom_settings = form.custom_settings
    @component.admin_email = form.admin_email
    @component.description = form.description
    @component.users_action_end_date = add_fix_hour_for_users_action_end_date
    @component.end_date_message = form.end_date_message
    @component.help_button_info = form.help_button_info

    @settings_changed = @component.settings_changed?

    @component.save!
  end

  # overwritten method
  # add custom settings
  def restore_readonly_settings!
    browse_readonly_settings("global") do |attribute|
      form.settings[attribute] = @previous_settings.dig("global", attribute)
    end

    browse_readonly_settings("step") do |attribute|
      form.default_step_settings[attribute] = @previous_settings.dig("default_step", attribute) if form.default_step_settings.present?
      if form.step_settings.present?
        form.step_settings.each do |step_name, step|
          step[attribute] = @previous_settings.dig("steps", step_name, attribute)
        end
      end
    end

    # custom settings
    browse_readonly_settings("custom") do |attribute|
      form.settings[attribute] = @previous_settings.dig("custom", attribute)
    end
  end

  def add_fix_hour_for_users_action_end_date
    return if form.users_action_end_date.blank?

    form.users_action_end_date.end_of_day
  end

  def normalize_survey_ends_at!
    return unless [:surveys].include?(manifest.name) && form.settings.ends_at.present?

    form.settings.ends_at = form.settings.ends_at.end_of_day
  end
end
