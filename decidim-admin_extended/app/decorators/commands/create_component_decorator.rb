# frozen_string_literal: true

# Class Decorator - Extending Decidim::Admin::CreateComponent
#
# Command has been expanded with:
# overwritten method
# attributes
Decidim::Admin::CreateComponent.class_eval do
  private

  # overwritten method
  # added custom attributes
  def create_component
    @component = Decidim.traceability.create!(
      Decidim::Component,
      form.current_user,
      manifest_name: manifest.name,
      name: form.name,
      participatory_space: form.participatory_space,
      weight: form.weight,
      settings: form.settings,
      default_step_settings: form.default_step_settings,
      step_settings: form.step_settings,
      # custom
      custom_settings: form.custom_settings,
      description: form.description,
      admin_email: form.admin_email,
      users_action_end_date: form.users_action_end_date,
      end_date_message: form.end_date_message
    )
  end

  # Overwritten private method
  #
  # Prevent to create first page when creating pages component
  #
  # returns nothing
  def run_hooks
    unless manifest.name == :pages
      manifest.run_hooks(:create, @component)
    end
  end
end
