# frozen_string_literal: true

# Class Decorator - Extending Decidim::Admin::ComponentForm
#
# Form has been expanded with:
# additional attributes
# validation
# new method
Decidim::Admin::ComponentForm.class_eval do
  attribute :custom_settings, Hash[String => Object]
  attribute :description, String
  attribute :admin_email, String
  attribute :users_action_end_date, Date
  attribute :end_date_message, String

  validates :admin_email, presence: true, 'valid_email_2/email': { disposable: true }, if: -> (form) { form.admin_email.present? }

  validate :locations_exists
  validate :message_end_date_presence, if: :users_action_end_date_selected?

  def locations_exists
    errors.add(:custom_settings, 'Wybierz zakres poligonu') if custom_settings['locations'] == ''
  end

  def users_action_end_date_selected?
    users_action_end_date.present?
  end

  def message_end_date_presence
    unless end_date_message.present?
      errors.add(:end_date_message, "Nie może być puste")
    end
  end
end
