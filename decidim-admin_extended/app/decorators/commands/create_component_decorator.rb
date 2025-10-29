# frozen_string_literal: true

Decidim::Admin::CreateComponent.class_eval do
  # add custom attrs:
  # fetch_form_attributes :custom_settings, :description, :admin_email, :users_action_end_date, :end_date_message, :help_button_info

  private

  def attributes
    super.reverse_merge(
      {
        manifest_name: form.manifest.name,
        # add custom attrs:
        custom_settings: form.custom_settings,
        description: form.description, # for :study_notes
        admin_email: form.admin_email, # for: study_notes and general_plan_requests
        users_action_end_date: add_fix_hour_for_users_action_end_date, # for: expert_questions, consultation_map, remarks, custom_proposals
        end_date_message: form.end_date_message, # for: surveys
        help_button_info: form.help_button_info # for: :consultation_map
      }
    )
  end

  # Prevent to create first page when creating pages component
  def run_after_hooks
    return if [:pages].include?(form.manifest.name)

    form.manifest.run_hooks(:create, resource)
  end

  def run_before_hooks
    normalize_survey_ends_at!
  end


  # dla ankiety ustawiamy czas na koniec dnia przed przypisaniem wartości z formularza
  def normalize_survey_ends_at!
    return unless [:surveys].include?(form.manifest.name) && form.settings.ends_at.present?

    form.settings.ends_at = form.settings.ends_at.end_of_day
  end

  def add_fix_hour_for_users_action_end_date
    return if form.users_action_end_date.blank?

    form.users_action_end_date.end_of_day
  end
end
