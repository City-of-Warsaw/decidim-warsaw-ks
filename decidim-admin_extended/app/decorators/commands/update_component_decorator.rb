# frozen_string_literal: true

# Class Decorator - Extending Decidim::Admin::UpdateComponent
#
# Command has been expanded with:
# overwritten methods
# additional attribute
Decidim::Admin::UpdateComponent.class_eval do
  private

  # overwritten methode
  # additional attribute
  def update_component
    @previous_settings = @component.attributes["settings"].with_indifferent_access
    @component.name = form.name
    @component.weight = form.weight

    restore_readonly_settings!

    @component.settings = form.settings
    @component.default_step_settings = form.default_step_settings
    @component.step_settings = form.step_settings
    # custom
    @component.custom_settings = form.custom_settings
    @component.admin_email = form.admin_email
    @component.description = form.description
    @component.users_action_end_date = form.users_action_end_date
    @component.end_date_message = form.end_date_message

    @settings_changed = @component.settings_changed?

    @component.save!
  end

  # overwritten methode
  # expand with - return browse_readonly_settings for custom settings
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

    # custom
    browse_readonly_settings("custom") do |attribute|
      form.settings[attribute] = @previous_settings.dig("custom", attribute)
    end
  end
end
