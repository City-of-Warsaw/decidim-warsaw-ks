# frozen_string_literal: true

Decidim::Forms::Admin::DisplayConditionForm.class_eval do
  include ActiveModel::Validations::Callbacks

  after_validation :change_error_messages

  # Public method for changing error message values
  #
  # Errors for this element are displayed as full message, so name of the attribute is added in the beginning
  def change_error_messages
    errors[:question][0] = "To pole nie może być puste" if errors[:question].any?
    errors[:condition_question][0] = "To pole nie może być puste" if errors[:condition_question].any?
    errors[:answer_option][0] = "To pole nie może być pusta" if errors[:answer_option].any?
  end
end