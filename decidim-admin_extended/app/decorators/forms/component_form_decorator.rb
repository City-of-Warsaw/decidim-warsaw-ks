# frozen_string_literal: true

Decidim::Admin::ComponentForm.class_eval do
  # setting - used only by: study notes and consultation map
  attribute(:custom_settings, { String => Object })

  # setting - used only by: study notes
  attribute :description, String

  # setting - used only by: study notes and general plan request
  attribute :admin_email, String

  # column - used nearly by all components
  attribute :users_action_end_date, Date

  # column - used nearly by all components
  attribute :end_date_message, String

  # column - used only by: consultation map
  attribute :help_button_info, String

  validates :admin_email,
            presence: true,
            "valid_email_2/email": { disposable: true }, if: ->(form) { form.admin_email.present? }
  validates :users_action_end_date,
            :end_date_message,
            presence: true,
            if: ->(form) { form.with_users_action_disallowed_date? }
  validate :help_section_title

  def locations_exists
    errors.add(:custom_settings, "Wybierz zakres poligonu") if custom_settings["locations"] == ""
  end

  def help_section_title
    if settings.manifest.attributes == "help_section_title" && settings["help_section_title"].blank?
      errors.add(:settings, "Jeżeli opis nad komponentem jest włączony, tytuł nie może być pusty")
    end
  end

  # Check if users_action_end_date should be editable for this component
  # Component with manifest name: surveys, in its settings has its own: ends_at field
  # Component with manifest name: surveys, DOES NOT validates :end_date_message
  def with_users_action_disallowed_date?
    return false unless current_user.ad_admin? || current_user.ad_coordinator?

    [:expert_questions, :consultation_map, :remarks, :custom_proposals].include?(manifest.name)
  end
end
