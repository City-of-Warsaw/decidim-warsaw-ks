# frozen_string_literal: true
require 'obscenity/active_model'

Decidim::Forms::AnswerForm.class_eval do
  validates :body, obscenity: { message: :banned_word }, if: proc { |attrs| attrs[:body].present? }

  # OVERWRITTEN:
  # Remove ordinal number
  def label(idx)
    base = "#{translated_attribute(question.body)}"
    base += " #{mandatory_label}" if question.mandatory?
    base += " (#{max_choices_label})" if question.max_choices
    base
  end
end